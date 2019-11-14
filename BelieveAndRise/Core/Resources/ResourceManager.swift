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

    func loadLocalResources() {
        localResourceManager.loadLocalResources()
    }

    // MARK: - Establishing sync

    ///
    func hasMap(named mapName: String, checksum: Int32, preferredVersion: String) -> (hasNameMatch: Bool, hasNameAndChecksumMatch: Bool, usedPreferredVersion: Bool) {
        let matches = localResourceManager.maps.filter({ $0.name == mapName })
        return (
            hasNameMatch: matches.count > 1,
            hasNameAndChecksumMatch: matches.filter({ $0.checksum == checksum }).count == 1,
            true
        )
    }

    func infoForMap(named mapName: String, preferredChecksum: Int32, preferredEngineVersion: String) -> (mapInfo: Map, checksumMatch: Bool, usedPreferredEngineVersion: Bool)? {
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

    func hasEngine(_ version: String) -> Bool {
        return localResourceManager.engineVersions.contains(where: { $0.version == version })
    }

    func hasGame(name: String, version: String) {

    }

    // MARK: - Maps

    func minimapData(forMapNamed mapName: String) -> (data: [UInt16], dimension: Int)? {
        return localResourceManager.minimapData(forMapNamed: mapName, mipLevel: 2)
    }
}
