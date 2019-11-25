//
//  LocalResourceManager.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 14/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

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

    func refresh() {
        queue.sync {
            for engineVersion in engineVersions {
                engineVersion.unitsyncWrapper.refresh()
            }
        }
    }

    /// Must be called after
    func loadMaps() {
        queue.sync {
            self._loadMaps()
        }
    }
    func loadGames() {
        queue.async {
            self._loadGames()
        }
    }
    /// Searches for downloaded engines, and identifies their unitsync libraries.
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

        // Wipe previous cache
        games = []

        // A mapCount of -1 indicates an error in unitsync, and 0 indicates there are no maps to load.
        let gameCount = mostRecentUnitsync.gameCount
        guard gameCount > 0 else {
            return
        }

        for index in 0..<gameCount {
//            let gameName = mostRecentUnitsync.mod(at: index)
            let checksum = mostRecentUnitsync.gameChecksum(at: index)
            print(mostRecentUnitsync.gameInfo(at: index))
//            games.append(Game(
//                name: gameName,
//                checksum: checksum
//            ))
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
                checksum: checksum,
//                description: description,
                width: 1,//width,
                height: 1//height
            ))
        }
        print("\(Date()): Done!")
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
                    engineVersions.append(Engine(version: version, location: applicationURL, unitsyncWrapper: wrapper))
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
                let mostRecentUnitsync = self.engineVersions.first?.unitsyncWrapper else {
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
}

struct Engine {
    let version: String
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
//    let description: String

    let width: Int
    let height: Int
}
