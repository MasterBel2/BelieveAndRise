//
//  Formatter.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 12/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

/// Describes a set of functions required for providing an item to a `ListViewController`.
protocol ItemViewProvider {
    func view(forItemIdentifiedBy id: Int) -> NSView?
//    func headerView(forSectionDescribedBy list: ListProtocol) -> NSView
}

/// An `ItemViewProvider` that always returns nil
final class DefaultItemViewProvider: ItemViewProvider {
    func view(forItemIdentifiedBy id: Int) -> NSView? {
        return nil
    }
}

/// An `ItemViewProvider` that provides a default view for a battlelist item.
final class BattlelistItemViewProvider: ItemViewProvider {
    let list: List<Battle>

    init(list: List<Battle>) {
        self.list = list
    }

    func view(forItemIdentifiedBy id: Int) -> NSView? {
        guard let battle = list.items[id] else {
            return nil
        }
        let view = SingleColumnTableColumnRowView.loadFromNib()
        view.primaryLabel.stringValue = battle.founder
        view.secondaryLabel.stringValue = "\(battle.userList.itemCount - battle.spectatorCount) + \(battle.spectatorCount) / \(battle.maxPlayers)"
        return view
    }
}

/// An `ItemViewProvider` that provides a default view for a userlist item.
final class DefaultPlayerListItemViewProvider: ItemViewProvider {
    let list: List<User>

    init(list: List<User>) {
        self.list = list
    }

    func view(forItemIdentifiedBy id: Int) -> NSView? {
        guard let user = list.items[id] else {
            return nil
        }
        let view = SingleColumnTableColumnRowView.loadFromNib()
        view.primaryLabel.stringValue = user.profile.fullUsername
        view.secondaryLabel.stringValue = "\(user.status.rank)"
        return view
    }
}

final class DefaultMessageListItemViewProvider: ItemViewProvider {
    let messageList: List<ChatMessage>
    let userlist: List<User>

    init(messageList: List<ChatMessage>, userlist: List<User>) {
        self.messageList = messageList
        self.userlist = userlist
    }

    func view(forItemIdentifiedBy id: Int) -> NSView? {
        guard let message = messageList.items[id],
            let sender = userlist.items[message.senderID] else {
            return nil
        }
        let view = SingleColumnTableColumnRowView.loadFromNib()
        view.primaryLabel.stringValue = sender.profile.fullUsername
        view.secondaryLabel.stringValue = message.content
        return view
    }
}

final class BattleroomMessageListItemViewProvider: ItemViewProvider {
    let list: List<ChatMessage>
    let battleroom: Battleroom

    init(list: List<ChatMessage>, battleroom: Battleroom) {
        self.list = list
        self.battleroom = battleroom
    }

    func view(forItemIdentifiedBy id: Int) -> NSView? {
        guard let message = list.items[id]
            else {
            return nil
        }
        let user = battleroom.battle.userList.items[message.senderID] ?? User(profile: User.Profile(id: 0, fullUsername: message.senderName, lobbyID: ""))

        let view = ExtendedChatMessageView.loadFromNib()

        view.messageField.stringValue = message.content

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "[HH:mm:ss]"
        view.timeLabel.stringValue = dateFormatter.string(from: message.time)

        view.clanTagField.stringValue = user.profile.clans.first ?? ""
        view.clanTagField.textColor = NSColor(named: "minorMajorLabel")
        view.usernameField.stringValue = user.profile.username

        guard let battleStatus = battleroom.userStatuses[user.id] else {
            return view
        }

        let myAlly = battleroom.myBattleStatus.allyNumber
        if battleStatus.isSpectator || battleroom.myBattleStatus.isSpectator {
            //
        } else if battleStatus.allyNumber == myAlly {
            view.usernameField.textColor = NSColor(named: "userIsAlly")
        } else {
            view.usernameField.textColor = NSColor(named: "userIsEnemy")
        }

        // Alpha value makes chat too hard to read. Let's just leave that for the player list.
//        view.alphaValue = battleStatus.isReady && !battleStatus.isSpectator ? 1 : 0.3

        return view
    }
}
