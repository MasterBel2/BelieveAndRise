//
//  BattleController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 13/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

final class BattleController {

    // MARK: - Dependencies

    /// The battlelist associated with the server client this controller provides an outgoing interface for.
	let battleList: List<Battle>
    /// The battleroom the user is currently in, if the user has joined one.
	var battleroom: Battleroom?
    /// Provides controll of a spring process, for joining battles specified by the host.
    let springProcessController = SpringProcessController()
    private let windowManager: ClientWindowManager
    /// The server this controller provides an interface for.
	weak var server: TASServer?

    // MARK: - Properties

    /// A unique string used to identify this user when connecting to another host.
    let scriptPassword = String(0.hashValue)

    // MARK: - Lifecycle

    init(battleList: List<Battle>, windowManager: ClientWindowManager) {
		self.battleList = battleList
        self.windowManager = windowManager
	}

    // MARK: - Interacting with battles

    /// Joins the specified new battle. Will first execute `leaveBattle()` if already in one.
    ///
    /// This function does not check whether the specified battle is the battle already joined.
	func joinBattle(_ battleID: Int) {
        guard battleList.items[battleID] !== battleroom?.battle else {
            return
        }

        if battleroom != nil {
            // Leave the battle so we can join a new one. (We can't be in two at once.)
			leaveBattle()
		}
		
		guard let battle = battleList.items[battleID] else {
			return
		}

		if battle.hasPassword {
			// TODO: Prompt for password
		}
		server?.send(CSJoinBattleCommand(battleID: battleID, password: nil, scriptPassword: scriptPassword))
	}

    /// Removes the player from the battle; first locally, then with a message to the server.
	func leaveBattle() {
        battleroom = nil
        windowManager.destroyBattleroom()

		server?.send(CSLeaveBattleCommand())
	}

    // MARK: - Updating status

    /// Updates the user's status – first locally (for immediate user feedback), then notifies the server that the client's status has changed.
    func setBattleStatus(_ battleStatus: Battleroom.UserStatus) {
        guard let battleroom = battleroom else {
            return
        }
        // If we haven't "joined the battle", don't send updates to the battleroom, because it expects
        // that we've already joined the battle.
        if battleroom.battle.userList.items.keys.contains(battleroom.myID) {
            battleroom.updateUserStatus(battleStatus, forUserIdentifiedBy: battleroom.myID)
        }
        server?.send(CSMyBattleStatusCommand(
            battleStatus: battleStatus,
            color: battleroom.myColor
        ))
    }

    /// Sets a user status for the user.
    func setStatus(_ status: User.Status) {
        server?.send(CSMyStatusCommand(status: status))
    }

    /// Updates the user's color – first locally (for immediate user feedback), then notifies the server that the client's color has changed.
    func setColor(_ color: Int32) {
        guard let battleroom = battleroom else {
            return
        }
        battleroom.colors[battleroom.myID] = color
        server?.send(CSMyBattleStatusCommand(
            battleStatus: battleroom.myBattleStatus,
            color: color
        ))
    }

    // MARK: - Controlling the game

    /// Launches spring as a client connecting to the specified host. The player's battlestatus is appropriately set to "unready", and their status is updated to reflect their ingame state.
    func startGame() {
        guard let battleroom = battleroom,
            let myAccount = battleroom.battle.userList.items[battleroom.myID] else {
            return
        }
        setBattleStatus(battleroom.myBattleStatus.changing(isReady: false))
        springProcessController.launchSpringAsClient(
            andConnectTo: battleroom.battle.ip,
            at: battleroom.battle.port,
            with: myAccount.profile.fullUsername,
            and: scriptPassword,
            completionHandler: { [weak self] in
                guard let self = self,
                    let battleroom = self.battleroom else {
                        return
                }
                self.setStatus(myAccount.status.changing(isIngame: false))
            }
        )

        setStatus(myAccount.status.changing(isIngame: true))
    }
}
