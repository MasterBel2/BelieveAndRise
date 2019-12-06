//
//  ChatViewController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 10/9/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

final class ChatViewController: NSViewController, ChatBarControllerDelegate {

    // MARK: - User Interface

    @IBOutlet var stackView: NSStackView!

    let chatBarController = ChatBarController()
    let logViewController = ChatLogViewController()

    // MARK: - Dependencies

    private(set) var channel: Channel?
    var chatController: ChatController!

    // MARK: - Configuration

    func setChannel(_ channel: Channel?) {
        self.channel = channel

        guard let channel = channel else {
            chatBarController.isChatBarEnabled = false
            return
        }

        chatBarController.isChatBarEnabled = true
        logViewController.itemViewProvider = DefaultMessageListItemViewProvider(messageList: channel.messageList, userlist: channel.userlist)
        logViewController.sections.forEach(logViewController.removeSection(_:))
        logViewController.addSection(channel.messageList)
        logViewController.shouldDisplaySectionHeaders = false
        title = channel.title
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Appearance

        view.backgroundColor = .controlBackgroundColor

        // View components

        addChild(logViewController)
        stackView.addArrangedSubview(logViewController.view)

        addChild(chatBarController)
        stackView.addArrangedSubview(chatBarController.view)
		
		chatBarController.delegate = self

        // Data

        setChannel(channel)
    }

    // MARK: - ChatBarControllerDelegate

    func send(_ message: String) {
        guard let channel = channel else {
            return
        }
        chatController.sendMessage(message, toChannelNamed: channel.title)
    }

    // MARK: - LogViewControllerDelegate

    func ring(_ id: Int) {
        chatController.ring(id)
    }
}
