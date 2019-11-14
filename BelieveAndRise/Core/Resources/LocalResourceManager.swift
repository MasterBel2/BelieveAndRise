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

    // MARK: - Lifecycle

    func loadLocalResources() {
        queue.async {
            self._loadLocalResources()
        }
    }

    private func _loadLocalResources() {

        autodetectSpringVersions()

        engineVersions.sort(by: { $0.version > $1.version })
        guard let mostRecentUnitsync = engineVersions.first?.unitsyncWrapper else {
            return
        }
        let gameCount = mostRecentUnitsync.gameCount
        // A gameCount of -1 indicates an error; 0 would also crash, so we'll mask that out too
        if gameCount > 0 {
            for index in 0..<gameCount {
                //            let gameName = mostRecentUnitsync.mod(at: index)
                let checksum = mostRecentUnitsync.gameChecksum(at: index)
                print(mostRecentUnitsync.gameInfo(at: index))
                //            games.append(Game(
                //                name: gameName,
                //                checksum: checksum
                //            ))
            }
        }

        let mapCount = mostRecentUnitsync.mapCount
        // As above with the gameCount
        if mapCount > 0 {
            for index in 0..<mostRecentUnitsync.mapCount {
                let mapName = mostRecentUnitsync.mapName(at: index)
                let checksum = mostRecentUnitsync.mapChecksum(at: index)
                let description = mostRecentUnitsync.mapDescription(at: index)
                let width = mostRecentUnitsync.mapWidth(at: index)
                let height = mostRecentUnitsync.mapHeight(at: index)
                maps.append(Map(
                    name: mapName,
                    checksum: checksum,
                    description: description,
                    width: width,
                    height: height
                ))
            }
        }
    }

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
    }

    // MARK: - Retrieving data

    /**
     Retrieves an array of dimension * dimension pixels that form the minimap for the given map, where dimension = 1024 / (2^mipLevel).
     */
    func minimapData(forMapNamed mapName: String, mipLevel: Int) -> (data: [UInt16], dimension: Int)? {
        if let data = minimaps[mapName] {
            return data
        }
        return queue.sync {
            guard let mostRecentUnitsync = engineVersions.first?.unitsyncWrapper else {
                return nil
            }
            let dimension = 1024 / Int(pow(2, Float(mipLevel)))
            guard let mapIndex = maps.enumerated().first(where: { $0.element.name == mapName })?.offset,
                let data = mostRecentUnitsync.minimap(forMapAt: mapIndex, mipLevel: mipLevel) else {
                return nil
            }

            return (data, dimension)
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
    let description: String

    let width: Int
    let height: Int
}
