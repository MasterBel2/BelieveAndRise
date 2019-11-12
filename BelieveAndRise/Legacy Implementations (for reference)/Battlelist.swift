//
//  Battlelist.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 25/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation


protocol BattlelistDelegate: AnyObject {
	/// Notifies the delegate that the battlelist removed the battle at the given index.
	func battlelist(_ battlelist: Battlelist, didRemoveBattleAt index: Int)
	/// Notifies the delegate that the battlelist added the battle at the given index.
	func battlelist(_ battlelist: Battlelist, didAddBattleAt index: Int)
	/// Notifies the delegate that the battelist added a battle at the given range
	func battlelist(_ battlelist: Battlelist, didUpdateBattlesIn range: Range<Int>)
}

protocol BattlelistDataSource: AnyObject {
	
}

/// A list of battles encapsulated by a structure that provides helper methods for accessing
/// and modifying those battles.
final class Battlelist {
	
    /// An unsorted list of battles indexed by ID.
	private(set) var battles: [Int : Battle] = [:]
	
	// battleID : index
    /// The battle's location in the sorted array, keyed by the battle's ID.
	private var sortKey: [Int : Int] = [:]
	
	/// Contains an array of IDs of battles, sorted in the order of most players to least players.
	private var sortedBattles: [Int] = []
	
    /// Returns the number of battles.
	private var battleCount: Int {
		return sortedBattles.count
	}
	
    /// The battlelist's delegate.
	weak var delegate: BattlelistDelegate?
    /// The battlelist's data source.
	weak var dataSource: BattlelistDataSource?
	
	// MARK: - Updating battlelist
	
	/// Adds the battle to the list with the given ID
	func addBattle(_ battle: Battle, with id: Int) {
		battles[id] = battle
		
		for index in 0..<battleCount {
			// can assume that player count is 1 – the host
			if battles[sortedBattles[index]]!.playerCount == 1 {
				sortedBattles.insert(id, at: index)
				sortKey[id] = index
			}
			delegate?.battlelist(self, didAddBattleAt: index)
			return
		}
	}
	
	/// Removes the battle with the given ID from the list, if one is present
	func removeBattle(withID id: Int) {
		guard let index = sortKey[id] else {
			return
		}
		sortedBattles.remove(at: index)
		sortKey.removeValue(forKey: id)
		battles.removeValue(forKey: id)
		
		delegate?.battlelist(self, didRemoveBattleAt: index)
	}
	
    /// Adds the user with the given ID to the battle
	func addUserWithID(_ userID: Int, toBattleWithID battleID: Int) {
		guard let battleIndex = sortKey[battleID],
			let updatedBattle = battles[battleID]  else {
				return
		}
		
		// 1. Add user to the battle
        battles[battleID]?.userList.addItemFromParent(id: userID)

		// 2. Adjust sorting of battles
		
		// this is surprisingly non-performant with all the operations that must take place :/
		var iteration = 0
		while updatedBattle.playerCount < battles[sortedBattles[battleIndex - 1]]!.playerCount {
			/// index of the updated battle
			let i = battleIndex - iteration
			/// index of the other battle
			let j = battleIndex - iteration - 1
			
			sortedBattles.swapAt(i, j)
			sortKey[battleID] = i
			sortKey[sortedBattles[battleIndex - 1]]! = j
			
			iteration += 1
		}
	}
	
	func removeUserWithID(_ userID: Int, toBattleWithID battleID: Int) {
		guard let battleIndex = sortKey[battleID],
			let updatedBattle = battles[battleID]  else {
				return
		}
		
		// 1. Add user to the battle
        battles[battleID]?.userList.removeItem(withID: userID)
		
		// 2. Adjust sorting of battles
		
		// this is surprisingly non-performant with all the operations that must take place :/
		var iteration = 0
		while updatedBattle.playerCount < battles[sortedBattles[battleIndex - 1]]!.playerCount {
			/// index of the updated battle
			let i = battleIndex - iteration
			/// index of the other battle
			let j = battleIndex - iteration - 1
			
			sortedBattles.swapAt(i, j)
			sortKey[battleID] = i
			sortKey[sortedBattles[battleIndex - 1]]! = j
			
			iteration += 1
		}
	}
	
	// MARK: - Retrieving battlelist information
	
	func battleID(at index: Int) -> Int {
		return sortedBattles[index]
	}
}
