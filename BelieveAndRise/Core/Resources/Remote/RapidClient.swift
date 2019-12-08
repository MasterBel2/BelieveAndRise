//
//  RapidClient.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 6/12/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation
protocol Downloader: AnyObject {
    var downloadName: String { get }
    var targetDirectory: URL { get }
    /// Cleans up all temporary directories, and if successful, moves the downloaded files to their intended destination.
    func finalizeDownload(_ successful: Bool)
}

final class RapidClient: Downloader, DownloaderDelegate {

    // MARK: - Dependencies

    weak var delegate: DownloaderDelegate?

    // MARK: - Local Directories

    private static var cacheDirectory: URL {
        return springDataDirectory
    }

    private static var repositoriesDirectory: URL {
        cacheDirectory.appendingPathComponent("rapid", isDirectory: true)
    }

    private static var packageDirectory: URL {
        return cacheDirectory.appendingPathComponent("packages", isDirectory: true)
    }

    private static func packageLocalURL(_ packageName: String) -> URL {
        return packageDirectory.appendingPathComponent(packageName).appendingPathExtension("sdp")
    }

    private static var poolDirectory: URL {
        return cacheDirectory.appendingPathComponent("pool", isDirectory: true)
    }

    private static func versionsGZDirectory(forRepoNamed repoName: String) -> URL {
        return repositoriesDirectory.appendingPathComponent(repoName).appendingPathComponent("versions").appendingPathExtension("gz")
    }

    // MARK: - Remote targets

    private static let rapidRemote = URL(string: "https://packages.springrts.com")!
    private static let repositoriesURL = rapidRemote.appendingPathComponent("repos").appendingPathExtension(".gz")

    private static let packagesRemote = rapidRemote.appendingPathComponent("packages", isDirectory: true)
    private static let poolRemote = rapidRemote.appendingPathComponent("pool", isDirectory: true)

    private static func packageURL(_ packageName: String) -> URL {
        return packagesRemote.appendingPathComponent(packageName).appendingPathExtension("sdp")
    }

    // MARK: - Downloading a resource

    // Hold a reference so the completion of async downloading can be handled
    private var packageDownloader: ArrayDownloader?
    private var poolDownloader: ArrayDownloader?

    func download(_ name: String) {
        do {
            try downloadPackages(name)
        } catch {
            delegate?.downloader(self, downloadDidFailWithError: error)
        }
    }

    private func downloadPackages(_ name: String) throws {
        let repositoryIndexes = try FileManager.default.contentsOfDirectory(atPath: RapidClient.repositoriesDirectory.path)
        let indexCaches = repositoryIndexes.map(RapidClient.versionsGZDirectory(forRepoNamed:))
        let packages = indexCaches.compactMap({ sdpArchiveName(for: name, at: $0) })
        let packageDownloader = ArrayDownloader(
            resourceNames: packages.map({ $0 }),
            rootDirectory: RapidClient.packageDirectory,
            remoteURL: RapidClient.packagesRemote,
            pathExtension: "sdp",
            successCondition: .one
        )

        packageDownloader.delegate = self
        packageDownloader.attemptFileDownloads()

        self.packageDownloader = packageDownloader
    }

    private func downloadResourceData(_ packageURL: URL) {
        guard let data = FileManager.default.contents(atPath: packageURL.path) else {
            print("Failed to retrieve data from downloaded file")
            return
        }
        guard let unzippedData = data.gunzip() else {
            print("Failed to unzip file")
            return
        }
        let resourceNames = self.poolFiles(from: unzippedData).map({ (poolArchive: PoolArchive) -> String in
            let folderName = String(poolArchive.md5Digest.dropLast(30))
            let fileName = String(poolArchive.md5Digest.dropFirst(2))
            return "\(folderName)/\(fileName)"
        })
        let poolDownloader = ArrayDownloader(
            resourceNames: resourceNames,
            rootDirectory: RapidClient.poolDirectory,
            remoteURL: RapidClient.poolRemote,
            pathExtension: "gz",
            successCondition: .all
        )
        poolDownloader.delegate = self
        poolDownloader.attemptFileDownloads()

        self.poolDownloader = poolDownloader
    }

    // MARK: - DownloaderDelegate

    func downloaderDidBeginDownload(_ downloader: Downloader) {
        if downloader === packageDownloader {
            delegate?.downloaderDidBeginDownload(self)
        }
    }

    func downloader(_ downloader: Downloader, downloadHasProgressedTo progress: Int, outOf total: Int) {
        if downloader === poolDownloader {
            delegate?.downloader(self, downloadHasProgressedTo: progress, outOf: total)
        }
    }

    func downloader(_ downloader: Downloader, downloadDidFailWithError error: Error?) {
        delegate?.downloader(self, downloadDidFailWithError: error)
    }

    func downloader(_ downloader: Downloader, successfullyCompletedDownloadTo tempUrls: [URL]) {
        if downloader === poolDownloader {
            delegate?.downloader(self, successfullyCompletedDownloadTo: tempUrls)
        } else {
            guard tempUrls.count == 1,
                let url = tempUrls.first else {
                    return
            }
            downloadResourceData(url)
        }
    }

    // MARK: - Downloader

    var downloadName: String = ""
    var targetDirectory: URL {
        return RapidClient.poolDirectory
    }

    func finalizeDownload(_ successful: Bool) {
        if successful {
            self.poolDownloader?.finalizeDownload(successful)
            self.poolDownloader = nil
            self.packageDownloader?.finalizeDownload(successful)
            self.packageDownloader = nil
        }
    }

    // MARK: - Analysing data

    private func poolFiles(from data: Data) -> [PoolArchive] {
        if let string = String(data: data, encoding: .utf8) {
            print(string)
        }
        var remainingData = data
        var archives: [PoolArchive] = []
        while remainingData.count >= 25 {
            let fileNameLength = Int(remainingData[0])
            let fileName = fileNameLength == 0 ? "" : String(data: remainingData[1...fileNameLength], encoding: .utf8)!
            let md5Digest = remainingData[(fileNameLength + 1)..<(fileNameLength + 17)].map({
                return $0 < 16 ? "0" + String($0, radix: 16) : String($0, radix: 16)
            }).joined()
            let crc32 = Int(data: remainingData[(fileNameLength + 5)..<(fileNameLength + 21)])!
            let fileSize = Int(data: remainingData[(fileNameLength + 9)..<(fileNameLength + 25)])!
            archives.append(PoolArchive(fileName: fileName, md5Digest: md5Digest, crc32: crc32, fileSize: fileSize))
            if remainingData.count > (25 + fileNameLength) {
                remainingData = remainingData.advanced(by: 25 + fileNameLength)
            } else {
                break
            }
        }
        return archives
    }

    private func sdpArchiveName(for resourceName: String, at url: URL) -> String? {
        guard let data = FileManager.default.contents(atPath: url.path) else {
            return nil
        }
        guard let unzippedData = data.gunzip() else {
            return nil
        }
        guard let stringValue = String(data: unzippedData, encoding: .utf8) else {
            return nil
        }
        let archives = resources(from: stringValue)
        guard let resource = archives.first(where: { $0.name == resourceName }) ?? archives.last(where: { "\($0.shortName):\($0.tag)" == resourceName }) else {
            return nil
        }
        return resource.sdpArchiveName
    }

    private func resources(from index: String) -> [RapidArchiveInfo] {
        var resources: [RapidArchiveInfo] = []
        index.enumerateLines(invoking: { (line, _) in
            let components = line.replacingOccurrences(of: ",", with: " , ").split(separator: ",").map({ $0.trimmingCharacters(in: [" "])})
            guard components.count == 4 else {
                return
            }
            let otherComponents = components[0].split(separator: ":")
            resources.append(RapidArchiveInfo(
                shortName: String(otherComponents[0]),
                tag: String(otherComponents[1]),
                version: otherComponents.count == 3 ? String(otherComponents[2]) : nil,
                sdpArchiveName: String(components[1]),
                mutator: components[2] == "" ? nil : String(components[2]),
                name: String(components[3])
            ))
        })
        return resources
    }

    // MARK: - Nested types

    private struct PoolArchive {
        let fileName: String
        let md5Digest: String
        let crc32: Int
        let fileSize: Int
    }
}
