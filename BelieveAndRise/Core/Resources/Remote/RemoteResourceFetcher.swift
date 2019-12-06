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

final class RemoteResourceFetcher: DownloaderDelegate {

    // MARK: - Properties

    private var downloaders: [Downloader] = []
    private var completionHandler: ((Bool) -> Void)?

    // MARK: - Retrieving resources

    /// Attempts to retrieve a resource from either Rapid or the SpringFiles API. The completion handler calls true for successful
    /// download, and false for a faliure.
    func retrieve(_ resource: Resource, completionHandler: @escaping (Bool) -> Void) {
        self.completionHandler = completionHandler
        switch resource {
        case .engine, .map:
            retrieveSpringFilesArchivedResource(resource)
        case .game(let name):
            let rapidClient = RapidClient()
            rapidClient.delegate = self
            rapidClient.download(name)
            downloaders.append(rapidClient)
//            retrieveSpringFilesArchivedResource(name, category: "game")
        }
    }

    private func searchSpringFiles(for resource: Resource, completionHandler: @escaping ([SpringArchiveInfo]?) -> Void) {
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
            let results = try? jsonDecoder.decode([SpringArchiveInfo].self, from: data)

            completionHandler(results)
        }
        downloadTask.resume()
    }

    /// Downloads a single, complete resource from the SpringFiles API.
    private func retrieveSpringFilesArchivedResource(_ resource: Resource) {
        searchSpringFiles(for: resource, completionHandler: { results in
            guard let target = results?.first else {
                return
            }

            // 1. Check dependencies are downloaded
            #warning("Dependencies may not have been downloaded")

            // 2. For each mirror, one at a time until successful, attempt to download the file
            let downloader = ArrayDownloader(
                fileName: target.filename,
                rootDirectory: springDataDirectory.appendingPathComponent(resource.directory, isDirectory: true),
                remoteURLs: target.mirrors,
                successCondition: .one
            )

            downloader.delegate = self
            downloader.attemptFileDownloads()
            
            self.downloaders.append(downloader)
        })
    }

    // MARK: - DownloaderDelegate

    func downloaderDidBeginDownload(_ downloader: Downloader) {
        print("Beginning download…")
    }

    func downloader(_ downloader: Downloader, downloadHasProgressedTo progress: Int, outOf total: Int) {
        print("\(progress)/\(total) (\((progress * 100 / total))%)")
    }

    func downloader(_ downloader: Downloader, downloadDidFailWithError error: Error?) {
        print("Download failed!")
        completionHandler?(false)
        downloader.finalizeDownload(false)
        downloaders.removeAll(where: { $0 === downloader})
    }

    func downloader(_ downloader: Downloader, successfullyCompletedDownloadTo tempUrls: [URL]) {
        print("Download completed!")
        completionHandler?(true)
        downloader.finalizeDownload(true)
        downloaders.removeAll(where: { $0 === downloader})
    }
}
