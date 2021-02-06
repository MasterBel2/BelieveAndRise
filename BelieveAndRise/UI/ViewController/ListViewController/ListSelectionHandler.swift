//
//  ListSelectionHandler.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 13/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation
import UberserverClientCore
import SpringRTSReplayHandling

/// Executes an action corresponding to a selection on the behalf of a list.
protocol ListSelectionHandler {
	func primarySelect(itemIdentifiedBy id: Int)
	func secondarySelect(itemIdentifiedBy id: Int)
}

/// Executes select actions for a battle list.
struct DefaultBattleListSelectionHandler: ListSelectionHandler {
	
	let battleController: BattleController
	let battlelist: List<Battle>
	
	public init(battlelist: List<Battle>, battleController: BattleController) {
		self.battlelist = battlelist
		self.battleController = battleController
	}
	
	public func primarySelect(itemIdentifiedBy id: Int) {
		battleController.joinBattle(id)
	}
	
	public func secondarySelect(itemIdentifiedBy id: Int) {
		primarySelect(itemIdentifiedBy: id)
	}
}

/// Executes select actions for a list of replays.
struct ReplayListSelectionHandler: ListSelectionHandler {

    public init(replayList: List<Replay>, springProcessController: SpringProcessController) {
        self.replayList = replayList
        self.springProcessController = springProcessController
    }

    public let springProcessController: SpringProcessController
    public let replayList: List<Replay>

    public func primarySelect(itemIdentifiedBy id: Int) {
		if let first = replayList.items[id] {
			try? springProcessController.launchReplay(first, shouldRecordDemo: false)
		}
    }

    public func secondarySelect(itemIdentifiedBy id: Int) {}
}
