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
    let logViewController = ListViewController()

    // MARK: - Dependencies

    private(set) var channel: Channel?
    var chatController: ChatController!

    // MARK: - Configuration

    func setChannel(_ channel: Channel) {
		logViewController.itemViewProvider = DefaultMessageListItemViewProvider(list: channel.messageList)
        logViewController.sections.forEach(logViewController.removeSection(_:))
        logViewController.addSection(channel.messageList)
        logViewController.shouldDisplaySectionHeaders = false
        title = channel.title
        self.channel = channel
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        addChild(logViewController)
        stackView.addArrangedSubview(logViewController.view)

        addChild(chatBarController)
        stackView.addArrangedSubview(chatBarController.view)
		
		chatBarController.delegate = self
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
