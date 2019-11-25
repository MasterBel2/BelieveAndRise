//
//  ChatController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 25/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

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
