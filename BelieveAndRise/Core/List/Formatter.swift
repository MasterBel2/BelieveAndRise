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
        view.primaryLabel.stringValue = user.profile.username
        view.secondaryLabel.stringValue = "\(user.profile.lobbyID)"
        return view
    }
}
