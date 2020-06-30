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
    private(set) var games: [Game] = []
    private(set) var maps: [Map] = []
    private var minimaps: [String : (data: [UInt16], dimension: Int)] = [:]

    private var mostRecentUnitsync: UnitsyncWrapper? {
        return engineVersions.sorted(by: { $0.version > $1.version }).first?.unitsyncWrapper
    }

    // MARK: - Lifecycle

    /// Syncrhonously refreshes all unitsync instances
    func refresh() {
        queue.sync {
            for engineVersion in engineVersions {
                engineVersion.unitsyncWrapper.refresh()
            }
        }
    }

    /// Uses the most recent unitsync version to asynchronously load all maps from the data dir.
    ///
    /// Must be called after `loadEngines`.
    func loadMaps() {
        queue.sync {
            self._loadMaps()
        }
    }

    /// Uses the most recent unitsync version to asynchronously load all games from the data dir.
    ///
    /// Must be called after `loadEngines`.
    func loadGames() {
        queue.async {
            self._loadGames()
        }
    }
    /// Asynchronously searches for downloaded engines, and identifies their unitsync libraries.
    ///
    /// This function must be called before `loadGames()` or `loadMaps()` for either of them to be successful.
    func loadEngines() {
        queue.async {
            self.autodetectSpringVersions()
        }
    }

    private func _loadGames() {
        guard let mostRecentUnitsync = mostRecentUnitsync else {
            return
        }

        // Wipe previous cache.
        games = []

        // A mapCount of -1 indicates an error in unitsync, and 0 indicates there are no maps to load.
        let gameCount = mostRecentUnitsync.gameCount
        guard gameCount > 0 else {
            return
        }

        for index in 0..<gameCount {
            let checksum = mostRecentUnitsync.gameChecksum(at: index)
            let gameInfo = mostRecentUnitsync.gameInfo(at: index)
            if let gameName = gameInfo["name"]?.stringValue {
                games.append(Game(
                    name: gameName,
                    checksum: checksum
                ))
            }
        }

        print("\(Date()): Loaded Games!")
    }

    private func _loadMaps() {
        guard let mostRecentUnitsync = mostRecentUnitsync else {
            return
        }

        // Wipe previous cache
        maps = []

        // A mapCount of -1 indicates an error in unitsync, and 0 indicates there are no maps to load.
        let mapCount = mostRecentUnitsync.mapCount
        guard mapCount > 0 else {
            return
        }

        for index in 0..<mapCount {
//            print("\(Date()): Loading map \(index + 1)")
            let mapName = mostRecentUnitsync.mapName(at: index)
            let checksum = mostRecentUnitsync.mapChecksum(at: index)
//            let description = mostRecentUnitsync.mapDescription(at: index)
//            let width = mostRecentUnitsync.mapWidth(at: index)
//            let height = mostRecentUnitsync.mapHeight(at: index)
            maps.append(Map(
                name: mapName,
                checksum: checksum
            ))
        }
        print("\(Date()): Loaded maps!")
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
                wrapper.performBlockAndWait {
                    let version = wrapper.springVersion
                    engineVersions.append(Engine(
                            version: version,
                            isReleaseVersion: wrapper.isSpringVersionAReleaseVersion,
                            location: applicationURL,
                            unitsyncWrapper: wrapper
                        )
                    )
                }
            }
        }
        print("\(Date()): Loaded Engines!")
    }

    // MARK: - Retrieving data

    /**
     Retrieves an array of dimension * dimension pixels that form the minimap for the given map, where dimension = 1024 / (2^mipLevel).
     */
    func loadMinimapData(forMapNamed mapName: String, mipLevel: Int, completionBlock: @escaping ((data: [UInt16], dimension: Int)?) -> Void) {
        if let (data, dimension) = minimaps[mapName],
            dimension == 1024 / Int(pow(2, Float(mipLevel))) {
            completionBlock((data, dimension))
            return
        }
        queue.async { [weak self] in
            guard let self = self,
                let mostRecentUnitsync = self.mostRecentUnitsync else {
                completionBlock(nil)
                return
            }
            let dimension = 1024 / Int(pow(2, Float(mipLevel)))
            guard let mapIndex = self.maps.enumerated().first(where: { $0.element.name == mapName })?.offset,
                let data = mostRecentUnitsync.minimap(forMapAt: mapIndex, mipLevel: mipLevel) else {
                completionBlock(nil)
                return
            }

            completionBlock((data, dimension))
        }
    }

    func diemnsions(forMapNamed mapName: String) -> (width: Int, height: Int)? {
        return queue.sync {
            guard let mostRecentUnitsync = mostRecentUnitsync,
                let mapIndex = maps.enumerated().first(where: { $0.element.name == mapName })?.offset else {
                return nil
            }
            let width = mostRecentUnitsync.mapWidth(at: mapIndex)
            let height = mostRecentUnitsync.mapHeight(at: mapIndex)
            return (width, height)
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
    let checksum: Int32
}

struct Map {
    let name: String
    let checksum: Int32
    var dimensions: (width: Int, height: Int)?
}
