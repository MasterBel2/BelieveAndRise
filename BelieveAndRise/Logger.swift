//
//  Logger.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 20/4/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa
import UberserverClientCore

/// Provides an interface for debug-only logging.
final class Logger {

    struct Message {
        let timestamp = Date()
        let message: String
        let tag: Tag

        var description: String {
            return "\(timestamp) [\(tag.rawValue)] \(message)"
        }

        enum Tag: String {
            case General

            case BattleStatusUpdate
            case StatusUpdate

            case ServerError
        }
    }

    private init() {
        #if DEBUG
        let textViewController = TextViewController()
        let window = NSWindow(contentViewController: textViewController)
        window.title = "Log"

        self.viewController = textViewController
        self.logWindow = window

        window.orderFront(self)
        #else
        logWindow = nil
        viewController = nil
        #endif
    }

    private static let `logger` = Logger()
    #if DEBUG
    private static let path = NSHomeDirectoryURL().appendingPathComponent(".config")
        .appendingPathComponent("spring")
        .appendingPathComponent("debug.believeandrise.log").path
    #else
    private static let path = NSHomeDirectoryURL().appendingPathComponent(".config")
        .appendingPathComponent("spring")
        .appendingPathComponent("believeandrise.log").path
    #endif

    private let logWindow: NSWindow?
    private let viewController: TextViewController?

    private(set) var messages: [Logger.Message] = []
    private var previousWrite: String = "Start of log file"

    /// Adds a message to the application's log.
    static func log(_ message: String, tag: Message.Tag) {
        let newMessage = Message(message: message, tag: tag)
        logger.messages.append(newMessage)

        let newEntry = newMessage.description
        print(newEntry)
        let newWrite = logger.previousWrite + "\n" + newEntry
        write(newWrite)
        logger.previousWrite = newWrite
        logger.viewController?.addLine("\n" + newEntry)
    }

    private static func write(_ log: String) {
        try? log.write(toFile: path, atomically: true, encoding: .utf8)
    }
}
