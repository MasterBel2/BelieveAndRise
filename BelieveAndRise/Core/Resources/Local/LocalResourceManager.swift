//
//  LocalResourceManager.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 14/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/// Handles retrieving resources stored locally on disk.
final class LocalResourceManager {

    private let queue = DispatchQueue(label: "com.believeandrise.localresources")

    // MARK: - Resources

    private(set) var engineVersions: [Engine] = []

    /// Provides access to engine-related archives, such as mods, etc.
    var archiveLoader: ArchiveLoader?

    private var mostRecentUnitsync: UnitsyncWrapper? {
        return engineVersions.sorted(by: { $0.version > $1.version }).first?.unitsyncWrapper
    }

    // MARK: - Lifecycle

    /// Syncrhonously refreshes all unitsync instances
    func refresh() {
        queue.sync {
            archiveLoader?.archivesAreLoaded = false
            for engineVersion in engineVersions {
                engineVersion.unitsyncWrapper.refresh()
            }
        }
    }

    /// Asynchronously searches for downloaded engines, and identifies their unitsync libraries.
    ///
    /// This function must be called before `loadGames()` or `loadMaps()` for either of them to be successful.
    func loadEngines() {
        queue.async { [weak self] in
            self?.autodetectSpringVersions()
            self?.archiveLoader?.load()
        }
    }

    /// Attempts to auto-detect spring versions in common directories by attempting to initialise unitsync on their contents.
    private func autodetectSpringVersions() {
        let fileManager = FileManager.default
        let allApplicationURLs =
            fileManager.urls(for: .allApplicationsDirectory, in: .localDomainMask)
                .reduce([], { (result, url) -> [URL] in
                    let urls = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
                    return result + (urls ?? [])
                })
        for applicationURL in allApplicationURLs {
            let config = UnitsyncConfig(appURL: applicationURL)
            if let wrapper = UnitsyncWrapper(config: config) {
                let version = wrapper.springVersion
                archiveLoader = ArchiveLoader(unitsyncWrapper: wrapper)
                engineVersions.append(Engine(
                    version: version,
                    isReleaseVersion: wrapper.IsSpringReleaseVersion(),
                    location: applicationURL,
                    unitsyncWrapper: wrapper
                    )
                )
            }
        }
        print("\(Date()): Loaded Engines!")
    }

    // MARK: - Retrieving data

    /**
     Retrieves an array of dimension * dimension pixels that form the minimap for the given map, where dimension = 1024 / (2^mipLevel).
     */
    func loadMinimapData(forMapNamed mapName: String, mipLevel: Int, completionBlock: @escaping ((data: [UInt16], dimension: Int)?) -> Void) {
        queue.async { [weak self] in
            let dimension = 1024 / Int(pow(2, Float(mipLevel)))
            guard let maybeData = self?.archiveLoader?.mapArchives.first(where: { $0.name == mapName })?.miniMap.minimap(for: mipLevel),
                maybeData.count == dimension * dimension else {
                completionBlock(nil)
                return
            }

            completionBlock((maybeData, dimension))
        }
    }

    func diemnsions(forMapNamed mapName: String) -> (width: Int, height: Int)? {
        return queue.sync {
            guard let archive = archiveLoader?.mapArchives.first(where: { $0.name == mapName }) else {
                return nil
            }
            return (archive.width, archive.height)
        }
    }
}

struct Engine {
    let version: String
    let isReleaseVersion: Bool

    /// Returns a string that may be used to determine if it will sync with another engine version. For a release version, this is the major
    /// and minor versions of the engine. For other versions, it is the entire version string.
    var syncVersion: String {
        if !isReleaseVersion {
            return version
        }
        let versionComponents = version.components(separatedBy: ".") + ["0"]

        return versionComponents[0...1].joined(separator: ".")
    }

    let location: URL
    let unitsyncWrapper: UnitsyncWrapper
}

struct Game {
    let name: String
    let checksum: UInt32
}

struct Map {
    let checksum: UInt32
    var dimensions: (width: Int, height: Int)?
}
