//
//  ResourceManager.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 14/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

final class ResourceManager {

    private let localResourceManager = LocalResourceManager()
    private let remoteResourceFetcher = RemoteResourceFetcher()

    private let queue = DispatchQueue(label: "com.believeandrise.resourcemanager")

    // MARK: - Controlling resources

    /// Loads engines, maps, then games.
    func loadLocalResources() {
        localResourceManager.loadEngines()
        localResourceManager.loadMaps()
        localResourceManager.loadGames()
    }

    /// Downloads a resource, and calls a completion handler with a boolean value indicating whether the download
    /// was successful, including verifying that unitsync can now identify the newly downloaded resource.
    func download(_ resource: Resource, completionHandler: @escaping (Bool) -> Void) {
        remoteResourceFetcher.retrieve(resource, completionHandler: { [weak self] successful in
            guard let self = self else {
                return
            }
            if successful {
                self.localResourceManager.refresh()
                switch resource {
                case .engine(let (name, platform)):
                    fatalError()
                case .game(let name):
                    self.localResourceManager.loadGames()
                    completionHandler(self.hasGame(name: name))
                case .map(let name):
                    self.localResourceManager.loadMaps()
                    // We only care about the name match here. Checksum can be checked where sync is important.
                    let hasMap = self.hasMap(named: name, checksum: 0, preferredVersion: "").hasNameMatch
                    completionHandler(hasMap)
                }
            } else {
                completionHandler(false)
            }
        })
    }

    // MARK: - Establishing sync

    /// 
    func hasMap(named mapName: String, checksum: Int32, preferredVersion: String) -> (hasNameMatch: Bool, hasNameAndChecksumMatch: Bool, usedPreferredVersion: Bool) {
        let matches = localResourceManager.maps.filter({ $0.name == mapName })
        return (
            hasNameMatch: matches.count > 0,
            hasNameAndChecksumMatch: matches.filter({ $0.checksum == checksum }).count == 1,
            true
        )
    }

    /// Retrieves a set of information about the map, also determining whether the map located has a matching checksum. Supports
    /// two maps with the same name, but differing checksums.
    func infoForMap(named mapName: String, preferredChecksum: Int32, preferredEngineVersion: String)
        -> (mapInfo: Map, checksumMatch: Bool, usedPreferredEngineVersion: Bool)? {
        let matches = localResourceManager.maps.filter({ $0.name == mapName })
        let mapInfo: Map
        let checksumMatch: Bool
        let usedPreferredEngineVersion = false
        if let exactMatch = matches.filter({ $0.checksum == preferredChecksum }).first {
            mapInfo = exactMatch
            checksumMatch = true
        } else if let partialMatch = matches.first {
            mapInfo = partialMatch
            checksumMatch = false
        } else {
            return nil
        }
        return (
            mapInfo: mapInfo,
            checksumMatch: checksumMatch,
            usedPreferredEngineVersion: usedPreferredEngineVersion
        )
    }

    /// Whether the lobby has located an engine with the specified version.
    func hasEngine(_ version: String) -> Bool {
        return localResourceManager.engineVersions.contains(where: { $0.version == version })
    }

    /// Whether unitsync can find a game with the matching name. The name string should include the game's version.
    func hasGame(name: String) -> Bool {
        return false
    }

    // MARK: - Maps

    /// Loads a minimap of the given resolution. Calls the completion block four times as it loads from the lowest to the highest. (This is to ensure the user sees visual feedback through the loading process)
    func loadMinimapData(forMapNamed mapName: String, mipLevels: Range<Int>, completionBlock: @escaping ((data: [UInt16], dimension: Int)?) -> Void) {
        guard let mipLevel = mipLevels.last else {
            completionBlock(nil)
            return
        }
        localResourceManager.loadMinimapData(forMapNamed: mapName, mipLevel: mipLevel) { [weak self] result in
            completionBlock(result)
            if mipLevels.count > 1 {
                self?.loadMinimapData(forMapNamed: mapName, mipLevels: mipLevels.dropLast(), completionBlock: completionBlock)
            }
        }
    }
}
