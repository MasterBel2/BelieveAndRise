//
//  Client Bridging.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 12/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

struct SCBridgeClientFromCommand: SCCommand {
	
	let location: String
	let externalID: Int
	let externalUsername: String
	
	// MARK: - Manual Construction
	
	init(location: String, externalID: Int, externalUsername: String) {
		self.location = location
		self.externalID = externalID
		self.externalUsername = externalUsername
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 3, sentenceCount: 0),
			let externalID = Int(words[2]) else {
			fatalError()
			return nil
		}
		location = words[0]
		self.externalID = externalID
		externalUsername = words[2]
	}
	
	func execute(on client: Client) {
		#warning("TODO")
	}
	
	var description: String {
		return "BRIDGECLIENTFROM \(location) \(externalID) \(externalUsername)"
	}
}

struct SCUnbridgeClientFromCommand: SCCommand {
	
	let location: String
	let externalID: Int
	let externalUsername: String
	
	// MARK: - Manual Construction
	
	init(location: String, externalID: Int, externalUsername: String) {
		self.location = location
		self.externalID = externalID
		self.externalUsername = externalUsername
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 3, sentenceCount: 0),
			let externalID = Int(words[2]) else {
			fatalError()
			return nil
		}
		location = words[0]
		self.externalID = externalID
		externalUsername = words[2]
	}
	
	func execute(on client: Client) {
		#warning("TODO")
	}
	
	var description: String {
		return "UNBRIDGECLIENTFROM \(location) \(externalID) \(externalUsername)"
	}
}

struct SCJoinedFromCommand: SCCommand {
	
	let channelName: String
	let bridge: String
	let username: String

	// MARK: - Manual Construction
	
	init(channelName: String, bridge: String, username: String) {
		self.channelName = channelName
		self.bridge = bridge
		self.username = username
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 3, sentenceCount: 0) else {
			return nil
		}
		channelName = words[0]
		bridge = words[1]
		username = words[2]
	}
	
	func execute(on client: Client) {
		#warning("TODO")
	}
	
	var description: String {
		return "JOINEDFROM \(channelName) \(bridge) \(username)"
	}
}

struct SCLeftFromCommand: SCCommand {
	
	let channelName: String
	let username: String
	
	// MARK: - Manual Construction
	
	init(channelName: String, username: String) {
		self.channelName = channelName
		self.username = username
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 2, sentenceCount: 0) else {
			return nil
		}
		channelName = words[0]
		username = words[1]
	}
	
	func execute(on client: Client) {
		#warning("todo")
	}
	
	var description: String {
		return "LEFTFROM"
	}
}

struct SCSaidFromCommand: SCCommand {
	
	let channelName: String
	let username: String
	let message: String?
	
	// MARK: - Manual Construction
	
	init(channelName: String, username: String, message: String?) {
		self.channelName = channelName
		self.username = username
		self.message = message
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, sentences) = try? wordsAndSentences(for: description, wordCount: 2, sentenceCount: 0, optionalSentences: 1) else {
			return nil
		}
		
		channelName = words[0]
		username = words[1]
		message = sentences.count == 1 ? sentences[0] : nil
	}
	
	func execute(on client: Client) {
		#warning("todo")
	}
	
	var description: String {
		var string = "SAIDFROM \(channelName) \(username)"
		if let message = message {
			string += " \(message)"
		}
		return string
	}
}

struct SCClientsFromCommand: SCCommand {

    let channelName: String
	let bridge: String
    let clients: [String]

    // MARK: - Manual construction

	init(channelName: String, bridge: String, clients: [String]) {
        self.channelName = channelName
		self.bridge = bridge
        self.clients = clients
    }

    // MARK: - SCCommand

    init?(description: String) {
        guard let (words, sentences) = try? wordsAndSentences(for: description, wordCount: 2, sentenceCount: 1) else {
            return nil
        }
        channelName = words[0]
		bridge = words[1]
        clients = sentences[0].components(separatedBy: " ")
    }

    var description: String {
        return "CLIENTSFROM \(channelName) \(bridge) \(clients.joined(separator: " "))"
    }

    func execute(on client: Client) {
		#warning("todo")
    }
}

