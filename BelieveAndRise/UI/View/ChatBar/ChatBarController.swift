//
//  ChatBarController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 9/9/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

protocol ChatBarControllerDelegate: AnyObject {
    func sendMessage(toChannelNamed channelName: String)
}

final class ChatBarController: NSViewController, ChatBarDelegate {

    // MARK: - Interface

    /// The view controller's chat bar. Set in loadView
    private(set) var chatBar: ChatBar!

    // MARK: - Lifecycle

    /// Loads the chat bar from its XIB.
    override func loadView() {
        let chatBar = ChatBar.loadFromNib()
        chatBar.delegate = self
        view = chatBar
        self.chatBar = chatBar
    }

    // MARK: - ChatBarDelegate

    func chatBar(_ chatBar: ChatBar, shouldSendMessage message: String) -> Bool {
        return true
    }
}
