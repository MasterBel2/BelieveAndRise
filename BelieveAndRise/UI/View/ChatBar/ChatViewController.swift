//
//  ChatViewController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 10/9/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

final class ChatController {

    let server: TASServer
    let windowManager: WindowManager

    var channels: [ChannelSummary] = []

    struct ChannelSummary {
        let title: String
        let description: String
        let members: String
        let isPrivate: Bool
    }

    init(server: TASServer, windowManager: WindowManager) {
        self.server = server
        self.windowManager = windowManager
    }

    func ring(_ id: Int) {}

    func sendMessage(_ message: String, toChannelNamed channelName: String) {
        server.send(CSSayCommand(channelName: channelName, message: message))
    }

    func sendPrivateMessage(_ message: String, toUserIdentifiedBy id: Int) {

    }

    func ignoreUser(_ id: Int) {
        // 1. Present a prompt asking for a reason ????

        // 2. Allow discarding of message and cancelling of the ignore action on

        // 3. Send message on prompt completion
    }

    func unignoreUser(_ id: Int) {

    }

    func presentJoinChannelMenu() {
        //
    }

    func joinChannel(_ channelName: String) {
        if channels.first(where: { $0.title == channelName })?.isPrivate == true {
            // Present a prompt
        }
        server.send(CSJoinCommand(channelName: channelName, key: nil))
    }
}



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
