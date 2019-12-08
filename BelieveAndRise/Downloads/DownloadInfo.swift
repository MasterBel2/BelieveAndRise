//
//  DownloadInfo.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 7/12/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/// An encapsulation of information about a download operation.
final class DownloadInfo: Sortable {

    init(name: String, location: URL) {
        self.name = name
        self.location = location
    }

	/// The name of the download.
    let name: String
	/// The location the download will be stored to.
    let location: URL
	/// The date the download began.
    let dateBegan = Date()
	/// The current state of the download.
	var state: State = .loading
	var progress: Int = 0
	var target: Int = 0
	
	/// Percent is an integer between 0 and 100 representing download progress, where 0 represents a pre-download state, and progress == target indicates an indeterminate download
	
	
	enum State {
		/// The download is preparing.
		case loading
		/// The download is progressing
		case progressing
		/// The download is paused.
		case paused
		/// The download has failed.
		case failed
		/// The download has completed successfully.
		case completed
	}

    func relationTo(_ other: DownloadInfo, forSortKey sortKey: DownloadInfo.PropertyKey) -> ValueRelation {
        switch sortKey {
		case .dateBeganAscending:
			return ValueRelation(value1: other.dateBegan, value2: dateBegan)
		case .dateBeganDescending:
			return ValueRelation(value1: dateBegan, value2: other.dateBegan)
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
    }
}
