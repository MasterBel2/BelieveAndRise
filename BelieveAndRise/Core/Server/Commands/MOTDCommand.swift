//
//  MOTD.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 13/7/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/// See https://springrts.com/dl/LobbyProtocol/ProtocolDescription.html#MOTD:server
struct MOTDCommand: SCCommand {
    let payload: String

    init(payload: String) {
        self.payload = payload
    }

    init?(description: String) {
        payload = description
    }

    var description: String {
        return "MOTD \(payload)"
    }

    func execute(on connection: Connection) {
        print(payload)
    }
}

struct SCServerMessage: SCCommand {
	
	let message: String
	
	// MARK: - Manual Construction
	
	init(message: String) {
		self.message = message
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (_, sentences) = try? wordsAndSentences(for: description, wordCount: 0, sentenceCount: 1) else {
			return nil
		}
		message = sentences[0]
	}
	
	func execute(on connection: Connection) {
		#warning("")
	}
	
	var description: String {
		return "SERVERMSG \(message)"
	}
}

struct SCServerMessageBox: SCCommand {
	
	let message: String
	let url: URL?
	
	// MARK: - Manual Construction
	
	init(message: String, url: URL) {
		self.message = message
		self.url = url
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (_, sentences) = try? wordsAndSentences(for: description, wordCount: 0, sentenceCount: 1, optionalSentences: 1) else {
			return nil
		}
		message = sentences[0]
		url = sentences.count == 2 ? URL(string: sentences[1]) : nil
	}
	
	func execute(on connection: Connection) {
		#warning("")
	}
	
	var description: String {
		var string = "SERVERMSGBOX \(message)"
		if let url = url {
			string += " \(url)"
		}
		return string
	}
}

