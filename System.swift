//
//  System.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 5/2/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa

/// A set of platform-specific system functions.
protocol System {
//    func write(_ fileContents: String, to directory: URL)
    func showFile(_ fileName: String?, at directory: URL)
}

/// MacOS-specific system functions.
final class MacOS: System {

    // MARK: - Dependencies
    private let fileManager = FileManager.default

    // MARK: - System

    func showFile(_ fileName: String?, at directory: URL) {
        let fullDirectory: URL?
        if let fileName = fileName {
            fullDirectory = directory.appendingPathComponent(fileName)
        } else {
            fullDirectory = nil
        }
        NSWorkspace.shared.selectFile(fullDirectory?.path, inFileViewerRootedAtPath: directory.path)
    }

//    func write(_ fileContents: String, to directory: URL) {
//        guard let fileData = fileContents.data(using: .utf8) else {
//            fatalError("Fatal Error: cannot convert file contents from String to Data")
//        }
//        fileManager.createFile(atPath: directory.path, contents: fileData, attributes: nil)
//    }
}

