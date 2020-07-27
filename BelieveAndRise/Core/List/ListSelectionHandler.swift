//
//  ListSelectionHandler.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 13/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/// Executes an action corresponding to a selection on the behalf of a list.
protocol ListSelectionHandler {
	func primarySelect(itemIdentifiedBy id: Int)
	func secondarySelect(itemIdentifiedBy id: Int)
}

/// Executes select actions for a battle list.
struct DefaultBattleListSelectionHandler: ListSelectionHandler {
	
	let battleController: BattleController
	let battlelist: List<Battle>
	
	init(battlelist: List<Battle>, battleController: BattleController) {
		self.battlelist = battlelist
		self.battleController = battleController
	}
	
	func primarySelect(itemIdentifiedBy id: Int) {
		battleController.joinBattle(id)
	}
	
	func secondarySelect(itemIdentifiedBy id: Int) {
		primarySelect(itemIdentifiedBy: id)
	}
}

/// Executes select actions for a list of replays.
struct ReplayListSelectionHandler: ListSelectionHandler {
    let springProcessController: SpringProcessController
    let replayList: List<Replay>

    func primarySelect(itemIdentifiedBy id: Int) {
        if springProcessController.canLaunchSpring,
            let first = replayList.items[id] {
            let demoSpecification = first.specification
            let newSpecification = GameSpecification(
                allyTeams: demoSpecification.allyTeams,
                spectators: demoSpecification.spectators,
                demoFile: first.fileURL,
                hostConfig: HostConfig(
                    userID: nil,
                    username: "Viewer",
                    type: .user(lobbyName: "BelieveAndRise"),
                    address: ServerAddress(location: "", port: 8452),
                    rank: nil,
                    countryCode: nil
                ),
                startConfig: demoSpecification.startConfig,
                mapName: demoSpecification.mapName,
                mapHash: demoSpecification.mapHash,
                gameType: demoSpecification.gameType,
                modHash: demoSpecification.modHash,
                gameStartDelay: demoSpecification.gameStartDelay,
                mapOptions: demoSpecification.mapOptions,
                modOptions: demoSpecification.modOptions,
                restrictions: demoSpecification.restrictions
            )
            springProcessController.startSpringRTS(newSpecification, shouldRecordDemo: false, completionHandler: nil)
        }
    }

    func secondarySelect(itemIdentifiedBy id: Int) {}
}
