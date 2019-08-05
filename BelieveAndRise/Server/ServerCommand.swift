//
//  TASServerCommand.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 4/7/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/// A command formatted to be received by the server
protocol ServerCommand: CustomStringConvertible {}

struct LoginCommand: ServerCommand {
	let username: String
	let password: String
    let compatabilityFlags: Set<CompatabilityFlag>

    enum CompatabilityFlag: String {
        case lobbyIDInAddUser = "l"
        case channelTopicOmitsTime = "t"
        case sayForBattleChatAndSayFrom = "u"
        case scriptPasswords = "sp"
        case springEngineVersionAndNameInBattleOpened = "cl"
        case joinBattleRequestAcceptDeny = "b"
    }

	var description: String {
		let encodedPassword = password.md5()!.base64Encoded() // TODO: Error checking
        return "LOGIN \(username) \(encodedPassword) 0 * BelieveAndRise 0.01\t0\t" + (compatabilityFlags.map { $0.rawValue }).joined(separator: " ")
	}
}

struct RegisterCommand: ServerCommand {
	let username: String
	let password: String
	var description: String {
		let encodedPassword = password.md5()!.base64Encoded()
		return "REGISTER \(username) \(encodedPassword)"
	}
}
