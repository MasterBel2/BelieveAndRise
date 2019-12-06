//
//  ArrayDownloader.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 21/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

protocol DownloaderDelegate: AnyObject {
    func downloaderDidBeginDownload(_ downloader: Downloader)
    func downloader(_ downloader: Downloader, downloadHasProgressedTo progress: Int, outOf total: Int)
    func downloader(_ downloader: Downloader, downloadDidFailWithError error: Error?)
    func downloader(_ downloader: Downloader, successfullyCompletedDownloadTo tempUrls: [URL])
}

final class ArrayDownloader: NSObject, Downloader, URLSessionDelegate, URLSessionDownloadDelegate {

    // MARK: - Getting download progress information

    weak var delegate: DownloaderDelegate?

    // MARK: - Behaviour customisation

    enum SuccessCondition {
        case one
        case all
    }

    private let successCondition: SuccessCondition

    // MARK: - Properties

    private let rootDirectory: URL
    private let tempDirectory: URL

    /// The list of resource names. This does not include their expected file extension
    private let resources: [(fileName: String, remoteURL: URL)]
    private var downloadedResources: [String : URL] = [:]
    private var downloadTask: URLSessionDownloadTask?
    private var session: URLSession?

    private var indexOfCurrentDownload: Int = 0

    // MARK: - Constructors

    convenience init(resourceNames: [String], rootDirectory: URL, remoteURL: URL, pathExtension: String, successCondition: SuccessCondition) {
        let resources = resourceNames.map({
            (fileName: $0 + "." + pathExtension, remoteURL: remoteURL.appendingPathComponent($0).appendingPathExtension(pathExtension))
        })
        self.init(resources: resources, rootDirectory: rootDirectory, successCondition: successCondition)
    }

    convenience init(fileName: String, rootDirectory: URL, remoteURLs: [URL], successCondition: SuccessCondition) {
        let resources = remoteURLs.map({ (fileName: fileName, remoteURL: $0) })
        self.init(resources: resources, rootDirectory: rootDirectory, successCondition: successCondition)
    }

    init(resources: [(fileName: String, remoteURL: URL)], rootDirectory: URL, successCondition: SuccessCondition) {
        self.resources = resources
        self.rootDirectory = rootDirectory
        tempDirectory = rootDirectory.appendingPathComponent("temp", isDirectory: true)
        self.successCondition = successCondition
    }

    // MARK: - Downloading

    func attemptFileDownloads() {
        guard resources.count > 0 else {
            delegate?.downloader(self, successfullyCompletedDownloadTo: [])
            return
        }
        attemptFileDownload(at: 0)
    }

    private func attemptFileDownload(at index: Int) {
        // Notify the delegate that we're beginning. If we're only trying to download one file, then by starting a second time,
        // we've gone back to the start.
        if index == 0 || successCondition == .one {
            delegate?.downloaderDidBeginDownload(self)
        }
        indexOfCurrentDownload = index
        let resource = resources[index]
        // Check whether we've already downloaded the file, and don't download it again.
        if let url = locationOfPreviouslyDownloadedFile(named: resource.fileName) {
            successfullyDownloadedResource(named: resource.fileName, to: url)
            return
        }

        let urlSession: URLSession
        if successCondition == .one {
            // If we're only downloading one file, we should track the progress of that file. Otherwise, we'll just use our % of files
            // downloaded to track our progress. So for one file, we'll assign ourselves as the urlSession's delegate
            urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            self.session = urlSession
        } else {
            urlSession = .shared
        }

        let downloadTask = urlSession.downloadTask(with: resource.remoteURL)
        downloadTask.resume()
        self.downloadTask = downloadTask
    }

    private func locationOfPreviouslyDownloadedFile(named fileName: String) -> URL? {
        var location: URL?
        do {
            let rootURL = rootDirectory.appendingPathComponent(fileName)
            let tempURL = tempDirectory.appendingPathComponent(fileName)
            try [rootURL, tempURL].forEach { url in
                // Use the URL and its last component to allow paths to be included in the fileName
                let directoryContents = try FileManager.default.contentsOfDirectory(atPath: url.deletingLastPathComponent().path)
                if directoryContents.contains(url.lastPathComponent) {
                    location = url
                    // TempURL last so we can move temp files out of temp… or something like that
                }
            }
        } catch {
            return location
        }
        return location
    }

    // MARK: - Finalising downloads

    func finalizeDownload(_ successful: Bool) {
        if successful {
            downloadedResources.forEach({ try? FileManager.default.moveItem(at: $0.value, to: rootDirectory.appendingPathComponent($0.key)) })
        }
        try? FileManager.default.removeItem(at: tempDirectory)
    }


    private func downloadsFailed(at index: Int, error: Error) {
        if successCondition == .all {
            try! FileManager.default.removeItem(at: tempDirectory)
            self.delegate?.downloader(self, downloadDidFailWithError: error)
        } else {
            attemptFileDownload(at: index + 1)
        }
    }

    private func successfullyDownloadedResource(named fileName: String, to location: URL) {
        downloadedResources[fileName] = location

        if successCondition == .one || !(indexOfCurrentDownload < resources.endIndex - 1) {
            // If this is our last file, or the only file we needed to download, we're done!
            delegate?.downloader(self, successfullyCompletedDownloadTo: downloadedResources.map({ $0.value }))
        } else {
            delegate?.downloader(self, downloadHasProgressedTo: indexOfCurrentDownload, outOf: resources.count)
            attemptFileDownload(at: indexOfCurrentDownload + 1)
        }
    }

    // MARK: - URLSessionDelegate

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let resource = resources[indexOfCurrentDownload]
        let tempURL = self.tempDirectory.appendingPathComponent(resource.fileName)

        do {
            // Deleting last component from the URL allows path components to be included in the file name given to this function.
            try FileManager.default.createDirectory(atPath: tempURL.deletingLastPathComponent().path, withIntermediateDirectories: true, attributes: nil)
            // Move item, else it will be deleted at the end of this function.
            try FileManager.default.moveItem(at: location, to: tempURL)
            successfullyDownloadedResource(named: resource.fileName, to: tempURL)
        } catch {
            self.downloadsFailed(at: indexOfCurrentDownload, error: error)
            return
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if successCondition == .all {
            delegate?.downloader(self, downloadDidFailWithError: error)
        } else {

        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if successCondition == .one {
            delegate?.downloader(self, downloadHasProgressedTo: Int(totalBytesWritten), outOf: Int(totalBytesWritten))
        }
    }
}
