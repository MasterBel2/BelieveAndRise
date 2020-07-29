//
//  ArchiveLoader.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 29/7/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

/// A loader for Unitsync archives.
final class ArchiveLoader {
    let unitsyncWrapper: UnitsyncWrapper

    /// Whether the archives have been loaded.
    var archivesAreLoaded = false

    init(unitsyncWrapper: UnitsyncWrapper) {
        self.unitsyncWrapper = unitsyncWrapper
    }

    /// Retrieves the lists of archives from Unitsync.
    func load() {
        guard !archivesAreLoaded else { return }
        mapArchives = (0..<unitsyncWrapper.GetMapCount()).map({ index in
            return MapArchive(
                archiveIndex: index,
                archiveName: String(cString: unitsyncWrapper.GetMapName(index)),
                unitsyncWrapper: unitsyncWrapper
            )
        })
        modArchives = (0..<unitsyncWrapper.GetPrimaryModCount()).map({ index in
            return ModArchive(
                archiveIndex: index,
                unitsyncWrapper: unitsyncWrapper
            )
        })
        skirmishAIArchives = (0..<unitsyncWrapper.GetSkirmishAICount()).map({ index in
            return SkirmishAIArchive(
                archiveIndex: index,
                unitsyncWrapper: unitsyncWrapper
            )
        })
        archivesAreLoaded = true
    }

    private(set) var modArchives: [ModArchive] = []
    private(set) var mapArchives: [MapArchive] = []
    private(set) var skirmishAIArchives: [SkirmishAIArchive] = []
}
