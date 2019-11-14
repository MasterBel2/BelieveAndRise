//
//  BattleController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 13/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

final class BattleController {
	
	let battleList: List<Battle>
	var battleroom: Battleroom?
	let server: TASServer
	
	let scriptPassword = ""
	
	init(battleList: List<Battle>, server: TASServer) {
		self.battleList = battleList
		self.server = server
	}
	
	func joinBattle(_ battleID: Int) {
		if battleroom != nil {
			leaveBattle()
            // Ensure that we don't send a notification twice.
            #warning("Battleroom updates are not held in sync between all relevant objects. This may lead to unexpected behaviour in the future.")
            battleroom = nil
		}
		
		guard let battle = battleList.items[battleID] else {
			return
		}
		if battle.hasPassword {
			// Prompt for password
		}
		server.send(CSJoinBattleCommand(battleID: battleID, password: nil, scriptPassword: scriptPassword))
	}
	
	func leaveBattle() {
		server.send(CSLeaveBattleCommand())
	}
	
	func toggleSpectator() {}
	func toggleReady() {}
	func setAlly(_ number: Int) {}
	func setTeam(_ number: Int) {}
    func setColor(_ color: Int32) {}
}
