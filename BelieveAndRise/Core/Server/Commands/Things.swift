//
//  Things.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 12/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/**
Tells the client that the user has been ignored (usually as a result of the IGNORE command sent by the client, but other sources are also possible). Also see the IGNORE command. This command uses named arguments, see "Named Arguments" chapter of the Intro section.
*/
struct SCIgnoreCommand: SCCommand {
	
	let username: String
	let reason: String?
	
	// MARK: - Manual Construction
	
	init(username: String, reason: String) {
		self.username = username
		self.reason = reason
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, sentences) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 0, optionalSentences: 1) else {
			return nil
		}
		username = words[0]
		reason = sentences.count == 1 ? sentences[0] : nil
	}
	
	func execute(on connection: Connection) {
		#warning("todo")
	}
	
	var description: String {
		var string = "IGNORE \(username)"
		if let reason = reason {
			string += " \(reason)"
		}
		return string
	}
}

struct SCUnignoreCommand: SCCommand {
	
	let username: String
	
	// MARK: - Manual Construction
	
	init(username: String) {
		self.username = username
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 0) else {
			return nil
		}
		self.username = words[0]
	}
	
	func execute(on connection: Connection) {
		#warning("todo")
	}
	
	var description: String {
		return "UNIGNORE \(username)"
	}
}


struct SCIgnoreListBegin: SCCommand {
	
	// MARK: - Manual Construction
	
	init() {}
	
	// MARK: - SCCommand
	
	init?(description: String) {}
	
	func execute(on connection: Connection) {
		#warning("todo")
	}
	
	var description: String {
		return "IGNORELISTBEGIN"
	}
}


struct SCIgnoreList: SCCommand {
	
	let username: String
	let reason: String?
	
	// MARK: - Manual Construction
	
	init(username: String, reason: String) {
		self.username = username
		self.reason = reason
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, sentences) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 0, optionalSentences: 1) else {
			return nil
		}
		username = words[0]
		reason = sentences.count == 1 ? sentences[0] : nil
	}
	
	func execute(on connection: Connection) {
		#warning("todo")
	}
	
	var description: String {
		var string = "IGNORE \(username)"
		if let reason = reason {
			string += " \(reason)"
		}
		return string
	}
}

struct SCCIgnoreListEnd: SCCommand {
	
	// MARK: - Manual Construction
	
	init() {}
	
	// MARK: - SCCommand
	
	init?(description: String) {}
	
	func execute(on connection: Connection) {
		#warning("todo")
	}
	
	var description: String {
		return "IGNORELISTEND"
	}
}


struct SCCompFlags: SCCommand {
	
	let compatabilityFlags: [CompatabilityFlag]
	private let unrecognisedFlags: [String]
	
	// MARK: - Manual Construction
	
	init(compatabilityFlags: [CompatabilityFlag]) {
		self.compatabilityFlags = compatabilityFlags
		unrecognisedFlags = []
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 0, sentenceCount: 0, optionalWords: 1000) else {
			return nil
		}
		compatabilityFlags = words.compactMap({ CompatabilityFlag(rawValue: $0) })
		let compatabilityFlagValues = compatabilityFlags.map({ $0.rawValue })
		let unrecognisedFlags = words.filter({ !compatabilityFlagValues.contains($0) })
		self.unrecognisedFlags = unrecognisedFlags
	}
	
	func execute(on connection: Connection) {
		debugOnlyPrint("Unrecognised flags: \(unrecognisedFlags.joined(separator: " "))")
	}
	
	var description: String {
		return "COMPFLAGS \(compatabilityFlags.map({$0.rawValue}).joined(separator: " "))"
	}
}


struct SCRedirectCommand: SCCommand {
	
	let ip: String
	let port: Int
	
	// MARK: - Manual Construction
	
	init(ip: String, port: Int) {
		self.ip = ip
		self.port = port
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 2, sentenceCount: 0),
			let port = Int(words[1]) else {
			return nil
		}
		ip = words[0]
		self.port = port
	}
	
	func execute(on connection: Connection) {
		connection.redirect(to: ServerAddress(location: ip, port: port))
	}
	
	var description: String {
		return "REDIRECT \(ip) \(port)"
	}
}


struct SCFailed: SCCommand {
	
	// MARK: - Manual Construction
	
	init() {}
	
	// MARK: - SCCommand
	
	init?(description: String) {}
	
	func execute(on connection: Connection) {
		connection.receivedError(.failed)
	}
	
	var description: String {
		return "FAILED"
	}
}


/**
A command used to send information to clients in JSON format. (Currently rarely used.)
*/
struct SCJSON: SCCommand {
	
	let json: String
	
	// MARK: - Manual Construction
	
	init(json: String) {
		self.json = json
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		json = description
	}
	
	func execute(on connection: Connection) {
//		jsonCommandHandler.execute(json, on: connection)
	}
	
	var description: String {
		return "JSON " + json
	}
}


/**
Sent as the response to a PING command.
*/
struct SCPong: SCCommand {
	
	let time = Date()
	
	// MARK: - Manual Construction
	
	init() {}
	
	// MARK: - SCCommand
	
	init?(description: String) {}
	
	func execute(on connection: Connection) {
		#warning("todo")
	}
	
	var description: String {
		return "PONG"
	}
}


/**
Sent as the response to a STLS command. The client now can now start the tls connection. The server will send again the greeting TASSERVER.
*/
struct SCOK: SCCommand {
	
	// MARK: - Manual Construction
	
	init() {}
	
	// MARK: - SCCommand
	
	init?(description: String) {}
	
	func execute(on connection: Connection) {
		#warning("TODO")
	}
	
	var description: String {
		return "OK"
	}
}

