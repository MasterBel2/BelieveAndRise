//
//  Formatter.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 12/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa
import SpringRTSReplayHandling
import UberserverClientCore

/// Describes a set of functions required for providing an item to a `ListViewController`.
protocol ItemViewProvider {
    func tableView(_ listView: NSTableView, viewForItemIdentifiedBy id: Int) -> NSView?
}

/// Extends ItemViewProvider with a default implementation.
protocol _ItemViewProvider: ItemViewProvider {
    associatedtype ViewType: NibLoadable & NSView
}

extension _ItemViewProvider {
    func _view(for tableView: NSTableView) -> ViewType {
        return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(ViewType.nibName), owner: nil) as? ViewType
             ?? ViewType.loadFromNib()
    }
}

/// An `ItemViewProvider` that always provides a nil view.
struct DefaultItemViewProvider: ItemViewProvider {

    typealias ViewType = NSView

    func tableView(_ listView: NSTableView, viewForItemIdentifiedBy id: Int) -> NSView? {
        return nil
    }
}

/// Provides a simple view describing the map and date of replays.
struct ReplayListItemViewProvider: _ItemViewProvider {

    typealias ViewType = SingleColumnTableColumnRowView

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    weak var replayList: List<Replay>?
    func tableView(_ listView: NSTableView, viewForItemIdentifiedBy id: Int) -> NSView? {
        guard let item = replayList?.items[id] else {
            return nil
        }
        let view = _view(for: listView)
        view.primaryLabel.stringValue = item.gameSpecification.mapName
        view.secondaryLabel.stringValue = dateFormatter.string(from: item.header.gameStartDate)
        return view
    }
}


/// An `ItemViewProvider` that provides a default view for a battlelist item.
struct BattlelistItemViewProvider: _ItemViewProvider {

    typealias ViewType = SingleColumnTableColumnRowView

    let list: List<Battle>

    init(list: List<Battle>) {
        self.list = list
    }

    func tableView(_ listView: NSTableView, viewForItemIdentifiedBy id: Int) -> NSView? {
        guard let battle = list.items[id] else {
            return nil
        }
        let view = _view(for: listView)
        view.primaryLabel.stringValue = battle.founder
        view.secondaryLabel.stringValue = "\(battle.userList.sortedItemCount - battle.spectatorCount) + \(battle.spectatorCount) / \(battle.maxPlayers)"
        return view
    }
}

/// An `ItemViewProvider` that provides a default view for a userlist item.
struct DefaultPlayerListItemViewProvider: _ItemViewProvider {

    typealias ViewType = SingleColumnTableColumnRowView

    let list: List<User>

    init(list: List<User>) {
        self.list = list
    }

    func tableView(_ listView: NSTableView, viewForItemIdentifiedBy id: Int) -> NSView? {
        guard let user = list.items[id] else {
            return nil
        }
        let view = _view(for: listView)
        view.primaryLabel.stringValue = user.profile.fullUsername
        view.secondaryLabel.stringValue = "\(user.status.rank)"
        return view
    }
}

struct PlayerRankIngameUsernameItemViewProvider: _ItemViewProvider {

    typealias ViewType = RankIngameAndUsernameView

    let ingameImage = #imageLiteral(resourceName: "In Battle Icon")

    let playerList: List<User>

    func tableView(_ listView: NSTableView, viewForItemIdentifiedBy id: Int) -> NSView? {
        guard let player = playerList.items[id] else {
            return nil
        }

        let view = _view(for: listView)

        view.clanField.stringValue = player.profile.clans.first ?? ""
        view.usernameField.stringValue = player.profile.username

        view.rankImageView.displayRank(player.status.rank)
        view.ingameStatusView.image = player.status.isIngame ? ingameImage : nil


        view.alphaValue = player.status.isAway ? 0.5 : 1

        return view

    }
}

struct DefaultMessageListItemViewProvider: _ItemViewProvider {

    typealias ViewType = SingleColumnTableColumnRowView

    let messageList: List<ChatMessage>
    let userlist: List<User>

    init(messageList: List<ChatMessage>, userlist: List<User>) {
        self.messageList = messageList
        self.userlist = userlist
    }

    func tableView(_ listView: NSTableView, viewForItemIdentifiedBy id: Int) -> NSView? {
        guard let message = messageList.items[id],
            let sender = userlist.items[message.senderID] else {
            return nil
        }
        let view = _view(for: listView)

        view.primaryLabel.stringValue = sender.profile.fullUsername
        view.secondaryLabel.stringValue = message.content
        return view
    }
}

struct BattleroomPlayerListItemViewProvider: _ItemViewProvider {

    typealias ViewType = RankIngameAndUsernameView

    let battleroom: Battleroom
    let ingameImage = #imageLiteral(resourceName: "In Battle Icon")
    private var playerList: List<User> {
        return battleroom.battle.userList
    }

    init(battleroom: Battleroom) {
        self.battleroom = battleroom
    }

    func tableView(_ listView: NSTableView, viewForItemIdentifiedBy id: Int) -> NSView? {
        guard let player = playerList.items[id] else {
            return nil
        }

        let view = _view(for: listView)

        view.clanField.stringValue = player.profile.clans.first ?? ""
        view.usernameField.stringValue = player.profile.username

        view.rankImageView.displayRank(player.status.rank)
        view.ingameStatusView.image = player.status.isIngame ? ingameImage : nil

        let myAlly = battleroom.myBattleStatus.allyNumber
        if let battleStatus = battleroom.userStatuses[id] {
            if battleStatus.isSpectator {
                view.usernameField.textColor = .labelColor
            } else if battleStatus.allyNumber == myAlly {
                view.usernameField.textColor = NSColor(named: "userIsAlly")
            } else {
                view.usernameField.textColor = NSColor(named: "userIsEnemy")
            }
            view.alphaValue = battleStatus.isReady && !battleStatus.isSpectator ? 1 : 0.5
        }
        if let trueSkill = battleroom.trueSkill(for: id) {
            view.toolTip = String(trueSkill)
        }

        return view

    }
}

struct BattleroomMessageListItemViewProvider: _ItemViewProvider {
    typealias ViewType = ExtendedChatMessageView

    let list: List<ChatMessage>
    let battleroom: Battleroom

    init(list: List<ChatMessage>, battleroom: Battleroom) {
        self.list = list
        self.battleroom = battleroom
    }

    func tableView(_ listView: NSTableView, viewForItemIdentifiedBy id: Int) -> NSView? {
        guard let message = list.items[id]
            else {
            return nil
        }
        let user = battleroom.battle.userList.items[message.senderID] ?? User(profile: User.Profile(id: 0, fullUsername: message.senderName, lobbyID: ""))

        let view = _view(for: listView)

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
            view.usernameField.textColor = .controlTextColor
        } else if battleStatus.allyNumber == myAlly {
            view.usernameField.textColor = NSColor(named: "userIsAlly")
        } else {
            view.usernameField.textColor = NSColor(named: "userIsEnemy")
        }

        return view
    }
}
