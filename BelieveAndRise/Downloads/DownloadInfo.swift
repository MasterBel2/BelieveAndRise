//
//  DownloadInfo.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 7/12/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

final class DownloadInfo: Sortable {

    init(name: String, location: URL) {
        self.name = name
        self.location = location
    }

    let name: String
    let location: URL
    let dateBegan = Date()
    /// Integer between 0 and 100 representing download progress, where 0 represents a pre-download state, and progress == target indicates an indeterminate download
    var progress: Int = 0
    var target: Int = 0
    var isPaused: Bool = false
    var isCompleted: Bool = false

    func relationTo(_ other: DownloadInfo, forSortKey sortKey: DownloadInfo.PropertyKey) -> ValueRelation {
        switch sortKey {
		case .dateBeganAscending:
			return ValueRelation(value1: other.dateBegan, value2: dateBegan)
		case .dateBeganDescending:
			return ValueRelation(value1: dateBegan, value2: other.dateBegan)
        case .progress:
            return ValueRelation(value1: progress, value2: other.progress)
        case .name:
            return ValueRelation(value1: name, value2: other.name)
        }
    }

    enum PropertyKey {
		/// Order by date the download started, with the earliest at the top.
        case dateBeganAscending
		/// Order by date the download started, with the latest at the top
		case dateBeganDescending
        case name
        case progress
    }
}
