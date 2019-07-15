//
//  Model.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 24/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

struct Battle {
	var userIDs: [Int]
	var spectatorCount: Int = 0
	let map: Map
	
	var playerCount: Int {
		return userIDs.count - spectatorCount
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
	
	struct Map {
		let name: String
		let hash: Int
	}
    
    init(isReplay: Bool, natType: NATType, founder: String, founderID: Int, ip: String, port: Int, maxPlayers: Int, passworded: Bool, rank: Int, mapHash: Int, engineName: String, engineVersion: String, mapName: String, title: String, gameName: String) {
        self.isReplay = isReplay
        self.natType = natType
        self.founder = founder
        self.founderID = founderID
        userIDs = [founderID]
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
        
        #warning("Setting static value for property instead of passing in through initialiser")
        self.channel = ""
    }
	
	init() {
        self.init(
            isReplay: false,
            natType: .none,
            founder: "",
            founderID: 0,
            ip: "",
            port: 0,
            maxPlayers: 0,
            passworded: false,
            rank: 0,
            mapHash: 0,
            engineName: "",
            engineVersion: "",
            mapName: "",
            title: "",
            gameName: ""
        )
	}
}
