//
//  DownloadController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 7/12/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/// An object which controls information about current and previous download operations.
final class DownloadController: DownloaderDelegate, DownloadItemViewDelegate {

	/// Downloaders associated with the items in the download list.
	///
	/// Since download ID is assigned from 0, increasing every time a downloader is added, the ID of a download is also the index of its downloader.
    var downloaders: [Downloader] = []
	/// The controller's list of download operations.
    let downloadList = List<DownloadInfo>(title: "Downloads", sortKey: .dateBeganDescending)
    private var nextID = 0

	/// The display for the information about the download operations.
    weak var display: ListDisplay? {
        didSet {
            display?.addSection(downloadList)
        }
    }

    private let system: System

    init(system: System) {
        self.system = system
    }

	// MARK: - DownloaderDelegate

    func downloaderDidBeginDownload(_ downloader: Downloader) {
        let downloadInfo = DownloadInfo(
            name: downloader.downloadName,
            location: downloader.targetDirectory
        )

        downloadList.addItem(downloadInfo, with: nextID)
        downloaders.append(downloader)
        nextID += 1
    }

    func downloader(_ downloader: Downloader, downloadHasProgressedTo progress: Int, outOf total: Int) {
        guard let index = downloaders.enumerated().first(where: { $0.element === downloader })?.offset,
			let downloadItem = downloadList.items[index] else {
            return
        }
		
		if downloadItem.state != .paused {
			downloadItem.state = .progressing
		}
		downloadItem.state = .progressing
        downloadItem.progress = progress
        downloadItem.target = total
        downloadList.respondToUpdatesOnItem(identifiedBy: index)
    }

    func downloader(_ downloader: Downloader, downloadDidFailWithError error: Error?) {
        guard let index = downloaders.enumerated().first(where: { $0.element === downloader })?.offset,
		let downloadItem = downloadList.items[index] else {
            return
        }
		downloadItem.state = .failed
        downloadList.respondToUpdatesOnItem(identifiedBy: index)
    }

    func downloader(_ downloader: Downloader, successfullyCompletedDownloadTo tempUrls: [URL]) {
        guard let index = downloaders.enumerated().first(where: { $0.element === downloader })?.offset,
			let downloadItem = downloadList.items[index] else {
            return
        }
		downloadItem.state = .completed
        downloadList.respondToUpdatesOnItem(identifiedBy: index)
    }

    // MARK: - DownloadItemViewDelegate

    func showDownload(_ id: Int) {
        let targetDirectory = downloaders[id].targetDirectory
        print(targetDirectory)
        system.showFile(targetDirectory.lastPathComponent, at: targetDirectory.deletingLastPathComponent())
    }

    func pauseDownload(_ id: Int) {
        downloaders[id].pauseDownload()
        downloadList.items[id]?.state = .paused
        downloadList.respondToUpdatesOnItem(identifiedBy: id)
    }

    func resumeDownload(_ id: Int) {
        downloaders[id].resumeDownload()
        downloadList.items[id]?.state = .progressing
        downloadList.respondToUpdatesOnItem(identifiedBy: id)
    }
}
