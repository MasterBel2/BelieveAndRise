//
//  Channel.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 24/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

class Channel: Sortable {
    let id = 0

    let title: String
    let userlist: List<User>
	var topic: String = ""

    private(set) var messageList: List<ChatMessage>

    // MARK: - Lifecycle

    init(title: String) {
        topic = title
        self.title = title
        userlist = List<User>(title: title, sortKey: .rank)
        messageList = List<ChatMessage>(title: title, sortKey: .time)
    }

    // MARK: - Sortable

    enum PropertyKey {
        case id
    }

    func relationTo(_ other: Channel, forSortKey sortKey: Channel.PropertyKey) -> ValueRelation {
        switch sortKey {
        case .id:
            return ValueRelation(value1: self.id, value2: other.id)
        }
    }

    func receivedNewMessage(_ message: ChatMessage) {
        messageList.addItem(message, with: messageList.itemCount)
    }
}

/// A chat message received from another client in a channel or private message.
struct ChatMessage: Sortable {
    let time: Date
    let sender: String
    let content: String
    let isIRCStyle: Bool

    enum PropertyKey {
        case time
    }

    func relationTo(_ other: ChatMessage, forSortKey sortKey: ChatMessage.PropertyKey) -> ValueRelation {
        switch sortKey {
        case .time:
            return ValueRelation(value1: time, value2: time)
        }
    }
}

enum ServerError {
    case joinFailed(channel: String, reason: String)
	case joinBattleFailed(reason: String)
	case resetPasswordDenied(errorMessage: String)
	case resetPasswordRequestDenied(errorMessage: String)
	case resendVerificationDenied(errorMessage: String)
	case changeEmailDenied(errorMessage: String)
	case changeEmailRequestDenied(errorMessage: String)
	case registrationDenied(reason: String)
	case loginDenied(reason: String)
	/// A command sent to the server has either failed, been denied, or otherwise cannot be completed.
	/// This normally is used as a generic error command, to inform lobby/client developers that they have not used the protocol correctly.
	case failed
	case openBattleFailed(reason: String)
}
