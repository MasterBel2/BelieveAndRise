//
//  Server.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 24/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

struct ServerModel {
	// Channel list
	var channels: [Channel] = []
	var battlelist = Battlelist()
	// User list
	var users: [User] = []
	
	var battleroom: Battleroom?
}
