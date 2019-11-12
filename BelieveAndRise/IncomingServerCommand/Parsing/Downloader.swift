//
//  Downloader.swift
//  BelieveAndRise
//
//  Created by Derek Bel on 28/8/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/// Provides an interface to the PR-Downloader application
final class Downloader {
	
	// MARK: - Configuration
	
	var shouldKeepConsolidatedRapidDownloads: Bool = true
	
	// MARK: - Properties
	
	/// A list of previous download requests
	private(set) var downloadRequests: [DownloadRequest] = []
	
	// MARK: - Internal API
	
	func downloadGame(named gameName: String, version: String) {}
	func downloadMap(named mapName: String) {}
	
	// MARK: - Nested Types
	
	struct DownloadRequest {
		let title: String
		var state: State
		var updates: [Update]
		
		enum State {
			case inProgress
			case failed
			case waiting
			case cancelled
			case readyForConsolidation
			case readyForValidation
			case validated
		}
		
		struct Update {
			let time: Date
			let title: String
		}
	}
}
