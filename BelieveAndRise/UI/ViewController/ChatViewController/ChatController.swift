//
//  ChatController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 25/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/// Controls the model associated with channel and private messaging, and associated functionality.
final class ChatController {

    /// The server the controller is associated with.
    weak var server: TASServer?
    /// Provides an API for the user interface associated with this 
    let windowManager: ClientWindowManager

    var channels: [ChannelSummary] = []

    struct ChannelSummary {
        let title: String
        let description: String
        let members: String
        let isPrivate: Bool
    }

    init(windowManager: ClientWindowManager) {
        self.windowManager = windowManager
    }

    func ring(_ id: Int) {}

    func sendMessage(_ message: String, toChannelNamed channelName: String) {
        server?.send(CSSayCommand(channelName: channelName, message: message))
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
        server?.send(CSJoinCommand(channelName: channelName, key: nil))
    }
}
