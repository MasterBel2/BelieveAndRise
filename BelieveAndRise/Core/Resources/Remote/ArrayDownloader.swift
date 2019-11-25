//
//  ArrayDownloader.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 21/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

protocol ArrayDownloaderDelegate: AnyObject {
    func downloadDidBegin()
    func downloadHasProgressed(to progress: Int, outOf total: Int)
    func downloadDidFail(withError: Error?)
    func downloadDidComplete()
}

final class ArrayDownloader: NSObject, URLSessionDelegate, URLSessionDownloadDelegate {

    // MARK: - Helper Types

    enum SuccessCondition {
        case one
        case all
    }

    // MARK: - Getting download progress information

    weak var delegate: ArrayDownloaderDelegate?

    // MARK: - Behaviour customisation

    private let successCondition: SuccessCondition

    private let rootDirectory: URL
    private let tempDirectory: URL

    /// The list of resource names. This does not include their expected file extension
    private let resources: [(fileName: String, remoteURL: URL)]
    private var downloadedResources: [String : URL] = [:]
    private var downloadTask: URLSessionDownloadTask?
    private var session: URLSession?

    private var completionHandler: ((Result<[URL], Error>) -> Void)?

    // MARK: - Properties

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

    func attemptFileDownloads(completionHandler: @escaping (Result<[URL], Error>) -> Void) throws {
        guard resources.count > 0 else {
            return
        }
        self.completionHandler = completionHandler
        attemptFileDownload(at: 0)
    }

    private func attemptFileDownload(at index: Int) {
        // Notify the delegate that we're beginning. If we're only trying to download one file, then by starting a second time,
        // we've gone back to the start.
        if index == 0 || successCondition == .one {
            delegate?.downloadDidBegin()
        }
        let resource = resources[index]
        // Check whether we've already downloaded the file, and don't download it again.
        if let url = locationOfPreviouslyDownloadedFile(named: resource.fileName) {
            self.downloadedResources[resource.fileName] = url
            if self.successCondition == .one || !(index < self.resources.endIndex - 1) {
                // If this is our last file, or the only file we needed to download, we're done!
                delegate?.downloadDidComplete()
                self.completionHandler?(.success(downloadedResources.map({ $0.value })))
            } else {
                self.attemptFileDownload(at: index + 1)
            }
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

        let downloadTask = urlSession.downloadTask(with: resource.remoteURL, completionHandler: { [weak self] (urlOrNil, responseOrNil, errorOrNil) in
            guard let self = self else {
                return
            }
            guard let url = urlOrNil else {
                self.downloadsFailed(at: index, error: errorOrNil!)
                return
            }

            let tempURL = self.tempDirectory.appendingPathComponent(resource.fileName)

            do {
                // Deleting last component from the URL allows path components to be included in the file name given to this function
                try FileManager.default.createDirectory(atPath: tempURL.deletingLastPathComponent().path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                self.downloadsFailed(at: index, error: error)
                return
            }

            try! FileManager.default.moveItem(at: url, to: tempURL)
            self.downloadedResources[resource.fileName] = tempURL
            if self.successCondition == .one || !(index < self.resources.endIndex - 1) {
                self.completionHandler?(.success(self.downloadedResources.map({ $0.value })))
                // Run the completion handler first to make sure everything's complete (including
                // moving the file back to the directories)
                self.delegate?.downloadDidComplete()
            } else {
                self.attemptFileDownload(at: index + 1)
                self.delegate?.downloadHasProgressed(to: index, outOf: self.resources.count)
            }
        })
        downloadTask.resume()
        self.downloadTask = downloadTask
    }

    // MARK: - Finalising downloads

    private func downloadsFailed(at index: Int, error: Error) {
        if successCondition == .all {
            try! FileManager.default.removeItem(at: tempDirectory)
            self.delegate?.downloadDidFail(withError: error)
            completionHandler?(.failure(error))
        } else {
            attemptFileDownload(at: index + 1)
        }
    }

    func downloadsComplete() {
        downloadedResources.forEach({ try? FileManager.default.moveItem(at: $0.value, to: rootDirectory.appendingPathComponent($0.key)) })
        try? FileManager.default.removeItem(at: tempDirectory)
    }

    // MARK: - URLSessionDelegate

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        delegate?.downloadDidComplete()
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        delegate?.downloadDidFail(withError: error)
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
//        if downloadTask == self.downloadTask {
            delegate?.downloadHasProgressed(to: Int(totalBytesWritten), outOf: Int(totalBytesExpectedToWrite))
//        }
    }
}
