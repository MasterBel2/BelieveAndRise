//
//  Logger.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 20/4/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa

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
        let textViewController = TextViewController()
        let window = NSWindow(contentViewController: textViewController)
        window.title = "Log"

        self.viewController = textViewController
        self.logWindow = window

        window.orderFront(self)
    }

    private static let `logger` = Logger()
    private static let path = "~/.config/spring/believeandrise.log"

    private let logWindow: NSWindow
    private let viewController: TextViewController

    private(set) var messages: [Logger.Message] = []
    private var previousWrite: String = "Start of log file"

    /// Adds a message to the application's log.
    static func log(_ message: String, tag: Message.Tag) {
        #if DEBUG
        let newMessage = Message(message: message, tag: tag)
        logger.messages.append(newMessage)

        let newEntry = newMessage.description
        print(newEntry)
        let newWrite = logger.previousWrite + "\n" + newEntry
        write(newWrite)
        logger.previousWrite = newWrite
        logger.viewController.addLine("\n" + newEntry)
        #endif
    }

    private static func write(_ log: String) {
        let data = log.data(using: .utf8)
        let fileManager = FileManager.default
        fileManager.createFile(atPath: path, contents: data, attributes: nil)
    }
}
