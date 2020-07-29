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
    private let remoteResourceFetcher: RemoteResourceFetcher

    private let queue = DispatchQueue(label: "com.believeandrise.resourcemanager")

	init(downloadController: DownloadController, windowManager: WindowManager) {
        remoteResourceFetcher = RemoteResourceFetcher(
			downloadController: downloadController,
			windowManager: windowManager
		)
    }

    // MARK: - Controlling resources

    /// Loads engines, maps, then games.
    func loadLocalResources() {
        localResourceManager.loadEngines()
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
                    completionHandler(self.hasGame(name: name))
                case .map(let name):
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
    func hasMap(named mapName: String, checksum: Int32, preferredVersion: String) -> (hasNameMatch: Bool, hasChecksumMatch: Bool, usedPreferredVersion: Bool) {
        let matches = localResourceManager.archiveLoader!.mapArchives.filter({ $0.name == mapName })
        return (
            hasNameMatch: matches.count > 0,
            hasChecksumMatch: matches.filter({ $0.checksum == checksum }).count == 1,
            usedPreferredVersion: true
        )
    }

    func dimensions(forMapNamed name: String) -> (width: Int, height: Int)? {
        if let match = localResourceManager.archiveLoader!.mapArchives.first(where: { $0.name == name}) {
            return (match.width, match.height)
        }
        return nil
    }

    /// Whether the lobby has located an engine with the specified version.
    func hasEngine(version: String) -> Bool {
        return localResourceManager.engineVersions.contains(where: { $0.syncVersion == version })
    }

    /// Whether unitsync can find a game with the matching name. The name string should include the game's version.
    func hasGame(name: String) -> Bool {
        return localResourceManager.archiveLoader!.modArchives.contains(where: { $0.name == name })
    }

    // MARK: - Maps

    /// Loads a minimap of the given resolution. Calls the completion block for each mip level as it loads from the lowest to the highest. (This is to ensure the user sees visual feedback through the loading process.)
    func loadMinimapData(forMapNamed mapName: String, mipLevels: Range<Int>, completionBlock: @escaping ((data: [UInt16], dimension: Int)?) -> Void) {
        // Proces the largest mipLevel (lowest resolution) to the smallest (greatest resolution).
        for mipLevel in mipLevels.reversed() {
            queue.async { [weak self] in
                self?.localResourceManager.loadMinimapData(
                    forMapNamed: mapName,
                    mipLevel: mipLevel,
                    completionBlock: completionBlock
                )
            }
        }
    }
}
