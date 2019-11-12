//
//  TASServerCommand.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 4/7/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

struct CSLoginCommand: CSCommand {
    func execute(on server: LobbyServer) {
        #warning("TODO")
    }

    init?(description: String) {
        return nil
    }

    init(username: String, password: String, compatabilityFlags: Set<CompatabilityFlag>) {
        self.username = username
        self.password = password
        self.compatabilityFlags = compatabilityFlags
    }

	let username: String
	let password: String
    let compatabilityFlags: Set<CompatabilityFlag>

	var description: String {
		let encodedPassword = password.md5()!.base64Encoded() // TODO: Error checking
        return "LOGIN \(username) \(encodedPassword) 0 * BelieveAndRise Alpha\t0\t" + (compatabilityFlags.map { $0.rawValue }).joined(separator: " ")
	}
}

struct CSRegisterCommand: CSCommand {
    func execute(on server: LobbyServer) {
        #warning("TODO")
    }

    init?(description: String) { return nil }

    init(username: String, password: String) {
        self.username = username
        self.password = password
    }

	let username: String
	let password: String
	var description: String {
		let encodedPassword = password.md5()!.base64Encoded()
		return "REGISTER \(username) \(encodedPassword)"
	}
}
