//
//  Model.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 24/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

struct Battle: Sortable {
    
    let userList: List<User>
    let allyLists: [List<User>] = []
    let spectatorList: List<User>
	var spectatorCount: Int = 0
	let map: Map
	
	var playerCount: Int {
        return userList.itemCount - spectatorList.itemCount
	}
	
	let title: String
	let isReplay: Bool
	let channel: String
	
    let gameName: String
	let engineName: String
	let engineVersion: String
	
	let maxPlayers: Int
	let passworded: Bool
	let rank: Int
	
    let founder: String
	let founderID: Int
	let port: Int
	let ip: String
	let natType: NATType
	
	// MARK: - Nested types
	
	struct Map {
		let name: String
		let hash: Int
	}
	
	// MARK: - Lifecycle
    
    init(serverUserList: List<User>,
        isReplay: Bool, natType: NATType, founder: String, founderID: Int, ip: String, port: Int,
        maxPlayers: Int, passworded: Bool, rank: Int, mapHash: Int, engineName: String,
        engineVersion: String, mapName: String, title: String, gameName: String, channel: String) {

        // Lists
        userList = List<User>(title: "", sortKey: .rank, parent: serverUserList)
        spectatorList = List<User>(title: "Spectators", sortKey: .rank, parent: userList)

        self.isReplay = isReplay
        self.natType = natType
        self.founder = founder
        self.founderID = founderID
        self.ip = ip
        self.port = port
        self.maxPlayers = maxPlayers
        self.passworded = passworded
        self.rank = rank
        self.map = Map(name: mapName, hash: mapHash)
        
        self.engineName = engineName
        self.engineVersion = engineVersion
        self.title = title
        self.gameName = gameName

        self.channel = channel

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
