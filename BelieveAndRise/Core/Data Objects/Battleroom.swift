//
//  Battleroom.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 24/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

struct Battleroom {
	// Updated by CLIENTBATTLESTATUS command
	var userStatuses: [Int : UserStatus]
	// Updated by SETSCRIPTTAGS command
	var scriptTags: [ScriptTag]
	
	struct UserStatus {}
	struct ScriptTag {}
}
