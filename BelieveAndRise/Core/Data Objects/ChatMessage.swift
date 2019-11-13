//
//  ChatMessage.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 14/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/// A chat message received from another client in a channel or private message.
class ChatMessage: Sortable {

    init(time: Date, sender: String, content: String, isIRCStyle: Bool) {
        self.time = time
        self.sender = sender
        self.content = content
        self.isIRCStyle = isIRCStyle
    }

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
            return ValueRelation(value1: self.time, value2: other.time)
        }
    }
}
