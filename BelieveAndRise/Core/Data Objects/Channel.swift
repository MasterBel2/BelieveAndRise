//
//  Channel.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 24/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

class Channel: Sortable {

    let title: String
    let userlist: List<User>
	var topic: String = ""

    private(set) var messageList: List<ChatMessage>

    // MARK: - Lifecycle

    init(title: String, rootList: List<User>) {
        topic = title
        self.title = title
        userlist = List<User>(title: title, sortKey: .rank, parent: rootList)
        messageList = List<ChatMessage>(title: title, sortKey: .time)
    }

    // MARK: - Sortable

    enum PropertyKey {
        case title
    }

    func relationTo(_ other: Channel, forSortKey sortKey: Channel.PropertyKey) -> ValueRelation {
        switch sortKey {
        case .title:
			return ValueRelation(value1: self.title, value2: other.title)
        }
    }

    func receivedNewMessage(_ message: ChatMessage) {
        messageList.addItem(message, with: messageList.itemCount)
    }
}
