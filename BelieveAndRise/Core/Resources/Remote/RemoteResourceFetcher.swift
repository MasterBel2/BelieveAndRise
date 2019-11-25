//
//  SpringArchiveInfo.swift
//  ProjectPlayground
//
//  Created by MasterBel2 on 16/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation
import DataCompression

var springDataDirectory: URL {
    return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".spring")
}

// For downloading from rapid:
// 1. Ensure cached versions.gz are up-to-date
// 2. Locate resource in versions.gz
// 3. Identify versions to download (between latest version and current version)
// 4. Dowload versions and place files in the appropriate ~/.spring/pool/XX folder
// 5. Indicate download completion

// For downloading from torrent
// 1. Search https://api.springfiles.com/json.php?category=<category>&torrent=true&springname=<name>
// 2. Check dependencies are dowloaded
// 3. Download from mirror

final class RemoteResourceFetcher: ArrayDownloaderDelegate, RapidClientDelegate {

    private let rapidClient = RapidClient()
    private var downloader: ArrayDownloader?
    private var completionHandler: ((Bool) -> Void)?

    init() {
        rapidClient.delegate = self
    }

    func retrieve(_ resource: Resource, completionHandler: @escaping (Bool) -> Void) {
        self.completionHandler = completionHandler
        switch resource {
        case .engine, .map:
            retrieveHTTPResource(resource)
        case .game(let name):
            rapidClient.download(name)
//            retrieveHTTPResource(name, category: "game")
        }
    }

    func retrieveHTTPResource(_ resource: Resource) {
        guard let url = URL(string: "https://api.springfiles.com/json.php?category=\(resource.category)&torrent=true&springname=\(resource.name.replacingOccurrences(of: " ", with: "%20"))") else {
            return
        }
        let downloadTask = URLSession.shared.downloadTask(with: url) { [weak self] (urlOrNil, responseOrNil, errorOrNil) in
            guard let self = self else {
                return
            }
            guard let url = urlOrNil else {
                self.completionHandler?(false)
                return
            }
            let data = FileManager.default.contents(atPath: url.path)!
            let jsonDecoder = JSONDecoder()
            guard let something = try? jsonDecoder.decode([SpringArchiveInfo].self, from: data).first else {
                return
            }
            // 1. Check dependencies are downloaded
            #warning("Dependencies may not have been downloaded")
            let downloader = ArrayDownloader(
                fileName: something.filename,
                rootDirectory: springDataDirectory.appendingPathComponent(resource.directory, isDirectory: true),
                remoteURLs: something.mirrors,
                successCondition: .one
            )
            downloader.delegate = self
            // 2. For each mirror, one at a time until successful, attempt to download the file
            try? downloader.attemptFileDownloads(completionHandler: { result in
                switch result {
                case .success(_):
                    downloader.downloadsComplete()
                    print("Completed!")
                case .failure(let error):
                    print("Download failed!")
                    print(error)
                }
            })
            self.downloader = downloader
        }
        downloadTask.resume()
    }

    func downloadDidBegin() {
        print("Beginning download…")
    }

    func downloadHasProgressed(to progress: Int, outOf total: Int) {
        print("\(progress)/\(total) (\((progress * 100 / total))%)")
    }

    func downloadDidFail(withError: Error?) {
        print("Download failed!")
        completionHandler?(false)
    }

    func downloadDidComplete() {
        print("Download completed!")
        completionHandler?(true)
    }
}

protocol RapidClientDelegate: ArrayDownloaderDelegate {}

final class RapidClient {

    // MARK: - ?

    weak var delegate: RapidClientDelegate?

    // MARK: - Local Directories

    static var cacheDirectory: URL {
        return springDataDirectory
    }

    static var repositoriesDirectory: URL {
        cacheDirectory.appendingPathComponent("rapid", isDirectory: true)
    }

    static var packageDirectory: URL {
        return cacheDirectory.appendingPathComponent("packages", isDirectory: true)
    }
    static func packageLocalURL(_ packageName: String) -> URL {
        return packageDirectory.appendingPathComponent(packageName).appendingPathExtension("sdp")
    }
    static var poolDirectory: URL {
        return cacheDirectory.appendingPathComponent("pool", isDirectory: true)
    }
    static func versionsGZDirectory(forRepoNamed repoName: String) -> URL {
        return repositoriesDirectory.appendingPathComponent(repoName).appendingPathComponent("versions").appendingPathExtension("gz")
    }

    // MARK: - Remote targets

    static let rapidRemote = URL(string: "https://packages.springrts.com")!
    static let repositoriesURL = rapidRemote.appendingPathComponent("repos").appendingPathExtension(".gz")

    static let packagesRemote = rapidRemote.appendingPathComponent("packages", isDirectory: true)
    static let poolRemote = rapidRemote.appendingPathComponent("pool", isDirectory: true)

    static func packageURL(_ packageName: String) -> URL {
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
            print("Failed to download packages: \(error)")
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

        try packageDownloader.attemptFileDownloads(completionHandler: packagesDownloadCompletionHandler(_:))
    }

    private func packagesDownloadCompletionHandler(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard urls.count == 1,
                let url = urls.first else {
                    return
            }
            downloadResourceData(url)
        case .failure(let error):
            print(error)
        }
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
        poolDownloader.delegate = self.delegate
        do {
            try poolDownloader.attemptFileDownloads(completionHandler: poolDownloadCompletionHandler(_:))
        } catch {
            print("Failed to download packages: \(error)")
        }
    }

    private func poolDownloadCompletionHandler(_ result: Result<[URL], Error>) {
        switch result {
        case .success(_):
            print("Complete!")
            self.poolDownloader?.downloadsComplete()
            self.poolDownloader = nil
            self.packageDownloader?.downloadsComplete()
            self.packageDownloader = nil
        case .failure(let error):
            print(error)
        }
    }

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

    private struct PoolArchive {
        let fileName: String
        let md5Digest: String
        let crc32: Int
        let fileSize: Int
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
}
