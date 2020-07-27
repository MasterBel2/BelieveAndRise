//
//  Model.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 24/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

protocol BattleDelegate: AnyObject {
    func mapDidUpdate(to map: Battle.Map)
}

final class Battle: Sortable {

    // MARK: - Dependencies

    weak var delegate: BattleDelegate?

    // MARK: - Properties
    
    let userList: List<User>
	var spectatorCount: Int = 0
    var map: Map {
        didSet {
            if map != oldValue {
                delegate?.mapDidUpdate(to: map)
            }
        }
    }

	var playerCount: Int {
        return userList.sortedItemCount - spectatorCount
	}
	
	let title: String
	let isReplay: Bool
	let channel: String
	
    let gameName: String
	let engineName: String
	let engineVersion: String
	
	let maxPlayers: Int
	let hasPassword: Bool
	var isLocked: Bool = false
	let rank: Int
	
    let founder: String
	let founderID: Int
	let port: Int
	let ip: String
	let natType: NATType
	
	// MARK: - Nested types
	
    struct Map: Equatable {
		let name: String
		let hash: Int32
	}
	
	// MARK: - Lifecycle
    
    init(serverUserList: List<User>,
        isReplay: Bool, natType: NATType, founder: String, founderID: Int, ip: String, port: Int,
        maxPlayers: Int, hasPassword: Bool, rank: Int, mapHash: Int32, engineName: String,
        engineVersion: String, mapName: String, title: String, gameName: String, channel: String) {

        self.isReplay = isReplay
        self.natType = natType
        self.founder = founder
        self.founderID = founderID
        self.ip = ip
        self.port = port
        self.maxPlayers = maxPlayers
        self.hasPassword = hasPassword
        self.rank = rank
        self.map = Map(name: mapName, hash: mapHash)
        
        self.engineName = engineName
        self.engineVersion = engineVersion
        self.title = title
        self.gameName = gameName

        self.channel = channel
		
		userList = List<User>(title: "", sortKey: .rank, parent: serverUserList)
		
        userList.addItemFromParent(id: founderID)
    }
	
	// MARK: - Sortable
	
	enum PropertyKey {
		case playerCount
	}
	
	func relationTo(_ other: Battle, forSortKey sortKey: Battle.PropertyKey) -> ValueRelation {
		switch sortKey {
		case .playerCount:
			return ValueRelation(value1: self.playerCount, value2: other.playerCount)
		}
	}
}
