//
//  ListSelectionHandler.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 13/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

protocol ListSelectionHandler {
	func primarySelect(itemIdentifiedBy id: Int)
	func secondarySelect(itemIdentifiedBy id: Int)
}

final class DefaultBattleListSelectionHandler: ListSelectionHandler {
	
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
