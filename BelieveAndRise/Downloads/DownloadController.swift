//
//  DownloadController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 7/12/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

final class DownloadController: DownloaderDelegate, DownloadItemViewDelegate {

    var downloaders: [Downloader] = []
    let downloadList = List<DownloadInfo>(title: "Downloads", sortKey: .dateBeganDescending)
    private var nextID = 0

    weak var display: ListDisplay? {
        didSet {
            display?.addSection(downloadList)
        }
    }

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
        guard let index = downloaders.enumerated().first(where: { $0.element === downloader })?.offset else {
            return
        }
        downloadList.items[index]?.progress = progress
        downloadList.items[index]?.target = total
        downloadList.respondToUpdatesOnItem(identifiedBy: index)
    }

    func downloader(_ downloader: Downloader, downloadDidFailWithError error: Error?) {
        guard let index = downloaders.enumerated().first(where: { $0.element === downloader })?.offset else {
            return
        }
        // TODO
    }

    func downloader(_ downloader: Downloader, successfullyCompletedDownloadTo tempUrls: [URL]) {
        guard let index = downloaders.enumerated().first(where: { $0.element === downloader })?.offset else {
            return
        }
        downloadList.items[index]?.isCompleted = true
        downloadList.respondToUpdatesOnItem(identifiedBy: index)
    }

    // MARK: - DownloadItemViewDelegate

    func showDownload(_ id: Int) {
//        TODO
    }

    func pauseDownload(_ id: Int) {
        // TODO
    }

    func resumeDownload(_ id: Int) {
        // TODO
    }
}
