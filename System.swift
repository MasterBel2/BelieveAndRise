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
    func showFile(_ fileName: String?, at directory: URL)
}

/// MacOS-specific system functions.
final class MacOS: System {
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
}
