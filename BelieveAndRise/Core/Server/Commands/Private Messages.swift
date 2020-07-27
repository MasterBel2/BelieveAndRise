//
//  Private Messages.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 12/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

struct SCSayPrivateCommand: SCCommand {
	
	let username: String
	let message: String
	
	// MARK: - Manual Construction
	
	init(username: String, message: String) {
		self.username = username
		self.message = message
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, sentences) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 1) else {
			return nil
		}
		username = words[0]
		message = sentences[0]
	}
	
	func execute(on client: Client) {
		#warning("todo")
	}
	
	var description: String {
		return "SAYPRIVATE \(username) \(message)"
	}
}

struct SCSaidPrivateCommand: SCCommand {
	
	let username: String
	let message: String
	
	// MARK: - Manual Construction
	
	init(username: String, message: String) {
		self.username = username
		self.message = message
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, sentences) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 1) else {
			return nil
		}
		username = words[0]
		message = sentences[0]
	}
	
	func execute(on client: Client) {
		#warning("todo")
	}
	
	var description: String {
		return "SAIDPRIVATE \(username) \(message)"
	}
}

struct SCSayPrivateEXCommand: SCCommand {
	
	let username: String
	let message: String
	
	// MARK: - Manual Construction
	
	init(username: String, message: String) {
		self.username = username
		self.message = message
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, sentences) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 1) else {
			return nil
		}
		username = words[0]
		message = sentences[1]
	}
	
	func execute(on client: Client) {
		#warning("todo")
	}
	
	var description: String {
		return "SAYPRIVATEEX \(username) \(message)"
	}
}

struct SCSaidPrivateEXCommand: SCCommand {
	
	let username: String
	let message: String
	
	// MARK: - Manual Construction
	
	init(username: String, message: String) {
		self.username = username
		self.message = message
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, sentences) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 1) else {
			return nil
		}
		username = words[0]
		message = sentences[1]
	}
	
	func execute(on client: Client) {
		#warning("todo")
	}
	
	var description: String {
		return "SAIDPRIVATEEX \(username) \(message)"
	}
}
