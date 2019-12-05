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

    /// The battlelist associated with the server connection this controller provides an outgoing interface for.
	let battleList: List<Battle>
    /// The battleroom the user is currently in, if the user has joined one.
	var battleroom: Battleroom?
    /// Provides controll of a spring process, for joining battles specified by the host.
    let springProcessController = SpringProcessController()
    /// The server this controller provides an interface for.
	let server: TASServer

    // MARK: - Properties

    /// A unique string used to identify this user when connecting to another host.
    let scriptPassword = String(0.hashValue)

    // MARK: - Lifecycle

	init(battleList: List<Battle>, server: TASServer) {
		self.battleList = battleList
		self.server = server
	}

    // MARK: - Interacting with battles

    /// Joins the specified new battle. Will first execute `leaveBattle()` if already in one.
    ///
    /// This function does not check whether the specified battle is the battle already joined.
	func joinBattle(_ battleID: Int) {

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
		server.send(CSJoinBattleCommand(battleID: battleID, password: nil, scriptPassword: scriptPassword))
	}

    /// Removes the player from the battle; first locally, then by
	func leaveBattle() {
        battleroom = nil
		server.send(CSLeaveBattleCommand())
	}

    // MARK: - Updating status

    /// Updates the user's status – first locally (for immediate user feedback), then notifies the server that the client's status has changed.
    func setBattleStatus(_ battleStatus: Battleroom.UserStatus) {
        guard let battleroom = battleroom else {
            return
        }
        battleroom.setUserStatus(battleStatus, forUserIdentifiedBy: battleroom.myID)
        server.send(CSMyBattleStatusCommand(
            battleStatus: battleStatus,
            color: battleroom.myColor
        ))
    }

    /// Sets a user status for the user.
    func setStatus(_ status: User.Status) {
//        server.send()
    }

    /// Updates the user's color – first locally (for immediate user feedback), then notifies the server that the client's color has changed.
    func setColor(_ color: Int32) {
        guard let battleroom = battleroom else {
            return
        }
        battleroom.colors[battleroom.myID] = color
        server.send(CSMyBattleStatusCommand(
            battleStatus: battleroom.myBattleStatus,
            color: color
        ))
    }

    // MARK: - Controlling the game

    /// Launches spring as a client connecting to the specified host. The player's battlestatus is appropriately set to "unready", and their
    /// status is updated to reflect their ingame state.
    func startGame() {
        guard let battleroom = battleroom else {
            return
        }
        setBattleStatus(Battleroom.UserStatus(
            isReady: false,
            teamNumber: battleroom.myBattleStatus.teamNumber,
            allyNumber: battleroom.myBattleStatus.allyNumber,
            isSpectator: battleroom.myBattleStatus.isSpectator,
            handicap: battleroom.myBattleStatus.handicap,
            syncStatus: battleroom.myBattleStatus.syncStatus,
            side: battleroom.myBattleStatus.side
        ))
        springProcessController.launchSpringAsClient(
            andConnectTo: battleroom.battle.ip,
            at: battleroom.battle.port,
            with: "BelieveAndRise",
            and: scriptPassword,
            completionHandler: { [weak self] in
                guard let self = self,
                    let battleroom = self.battleroom else {
                        return
                }
//                setStatus(User.Status(
//                    isAway: <#T##Bool#>,
//                    isIngame: <#T##Bool#>,
//                    rank: <#T##Int#>,
//                    isModerator: <#T##Bool#>,
//                    isAutomatedAccount: <#T##Bool#>
//                ))
            }
        )
    }
}
