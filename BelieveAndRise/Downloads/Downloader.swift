//
//  Downloader.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 9/2/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

protocol Downloader: AnyObject {
    var downloadName: String { get }
    var targetDirectory: URL { get }
    /// Cleans up all temporary directories, and if successful, moves the downloaded files to their intended destination.
    func finalizeDownload(_ successful: Bool)
    // Pauses the download.
    func pauseDownload()
    // Resumes a paused download.
    func resumeDownload()
}
