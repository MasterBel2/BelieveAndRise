//
//  ChatViewController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 10/9/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa
import UberserverClientCore

/**
 

 The chat view controller is backed by a `ColoredView` to allow drawing of background colors. Use `setViewBackgroundColor` to modify
 this property.
 */
final class ChatViewController: NSViewController, ChatBarControllerDelegate {

    // MARK: - User Interface

    @IBOutlet var stackView: NSStackView!

    let chatBarController = ChatBarController()
    let logViewController = ChatLogViewController()

    // MARK: - Dependencies

    weak var authenticatedClient: AuthenticatedSession?
    private(set) var channel: Channel?

    // MARK: - Configuration

    func setChannel(_ channel: Channel?) {
        executeOnMain { [weak self] in
            guard let self = self else {
                return
            }
            self.channel = channel

            guard let channel = channel else {
                self.chatBarController.isChatBarEnabled = false
                return
            }

            self.chatBarController.isChatBarEnabled = true

            self.logViewController.sections.forEach(self.logViewController.removeSection(_:))
            self.logViewController.addSection(channel.messageList)
            self.logViewController.shouldDisplaySectionHeaders = false
            self.title = channel.title
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Appearance

        // View components

        addChild(logViewController)
        stackView.addArrangedSubview(logViewController.view)

        addChild(chatBarController)
        stackView.addArrangedSubview(chatBarController.view)
		
		chatBarController.delegate = self

        // Data

        setChannel(channel)
    }

    // MARK: - Modifying view appearance

    /// Sets a background color on the view controller's view.
    func setViewBackgroundColor(_ color: NSColor?) {
        (view as? ColoredView)?.backgroundColor = color
    }

    // MARK: - ChatBarControllerDelegate

    func send(_ message: String) {
        channel?.send(message)
    }

    // MARK: - LogViewControllerDelegate

    func ring(_ id: Int) {
        authenticatedClient?.ring(id)
    }
}
