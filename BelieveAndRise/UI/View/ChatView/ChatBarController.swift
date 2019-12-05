//
//  ChatBarController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 9/9/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

protocol ChatBarControllerDelegate: AnyObject {
    func send(_ message: String)
}

final class ChatBarController: NSViewController, ChatBarDelegate {
	
	// MARK: - Dependencies
	
	weak var delegate: ChatBarControllerDelegate?

    /**
     whether the chat bar is enabled.

     Don't retrieve this value directly; use `isChatBarEnabled`.
     */
    private var _isChatBarEnabled = true {
        didSet {
            if isViewLoaded {
                chatBar.isEnabled = isChatBarEnabled
            }
        }
    }

    var isChatBarEnabled: Bool {
        set {
            _isChatBarEnabled = newValue
        }
        get {
            return isViewLoaded ? chatBar.isEnabled : _isChatBarEnabled
        }
    }

    // MARK: - Interface

    /// The view controller's chat bar. Set in loadView
    private(set) var chatBar: ChatBar!

    // MARK: - Lifecycle

    /// Loads the chat bar from its XIB.
    override func loadView() {
        let chatBar = ChatBar.loadFromNib()
        chatBar.delegate = self
        chatBar.isEnabled = isChatBarEnabled
        view = chatBar
        self.chatBar = chatBar
    }

    // MARK: - ChatBarDelegate

    func chatBar(_ chatBar: ChatBar, shouldSendMessage message: String) -> Bool {
		delegate?.send(message)
        return true
    }
}

//protocol AccountAPI {
//
//}

//protocol ChannelAPI {
//    func channels()
//    func joinChannel(named channelName: String, password: String?)
//    func leaveChannel(named channelName: String)
//}
//
//protocol BattleAPI {
//    func joinBattle(identifiedBy id: Int, password: String?)
//    func leaveBattle()
//    func sendBattleStatus(_ userStatus: Battleroom.UserStatus, color: UInt32)
//}
