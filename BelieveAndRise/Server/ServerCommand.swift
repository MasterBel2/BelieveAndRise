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
	var description: String {
		let encodedPassword = password.md5()!.base64Encoded() // TODO: Error checking
		return "LOGIN \(username) \(encodedPassword) 0 * BelieveAndRise 0.01\t0\ta b cl p sp"
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
