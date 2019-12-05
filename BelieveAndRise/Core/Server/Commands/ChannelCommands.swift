//
//  JoinCommand.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 1/9/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/// 
struct SCJoinCommand: SCCommand {

    let channelName: String

    // MARK: - Manual construction

    init(channelName: String) {
        self.channelName = channelName
    }

    // MARK: - SCCommand

    init?(description: String) {
        if description == "" { return nil }
        self.channelName = description
    }

    var description: String {
        return "JOIN \(channelName)"
    }

    func execute(on connection: Connection) {
		let channelID = connection.id(forChannelnamed: channelName)
		guard connection.channelList.items[channelID] == nil else {
			return
		}
        let channel = Channel(title: channelName, rootList: connection.userList)
        connection.channelList.addItem(channel, with: channelID)
    }
}

struct SCJoinFailedCommand: SCCommand {

    let channelName: String
    let reason: String

    // MARK: - Manual construction

    init(channelName: String, reason: String) {
        self.channelName = channelName
        self.reason = reason
    }

    // MARK: - SCCommand

    init?(description: String) {
        guard let (words, sentences) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 1),
              let channelName = words.first,
              let reason = sentences.first else {
            return nil
        }
        self.channelName = channelName
        self.reason = reason
    }

    var description: String {
        return "JOINFAILED \(channelName) \(reason)"
    }

    func execute(on connection: Connection) {
        connection.receivedError(.joinFailed(channel: channelName, reason: reason))
    }
}

struct CSJoinCommand: CSCommand {

    let channelName: String
    let key: String?

    // MARK: - Manual construction

    init(channelName: String, key: String?) {
        self.channelName = channelName
        self.key = key
    }

    // MARK: - CSCommand

    init?(description: String) {
        guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 2, sentenceCount: 0, optionalWords: 1) else {
            return nil
        }
        self.channelName = words[0]
        self.key = nil
    }

    var description: String {
        return "JOIN \(channelName)"
    }

    func execute(on server: LobbyServer) {
        
    }
}

struct SCChannelTopicCommand: SCCommand {

    let channelName: String
    let author: String
    let topic: String

    // MARK: - Manual construction

    init(channelName: String, author: String, topic: String) {
        self.channelName = channelName
        self.author = author
        self.topic = topic
    }

    // MARK: - SCCommand

    init?(description: String) {
        guard let (words, sentences) = try? wordsAndSentences(for: description, wordCount: 2, sentenceCount: 1) else {
                return nil
        }
        channelName = words[0]
        author = words[1]
        topic = sentences[0]
    }

    var description: String {
        return "CHANNELTOPIC \(channelName) \(author) \(topic)"
    }

    func execute(on connection: Connection) {
		let channelID = connection.id(forChannelnamed: channelName)
        guard let channel = connection.channelList.items[channelID] else {
            return
        }
        channel.topic = topic
    }
}

/// A request to change a channel's topic, typically sent by a priveleged user.
struct CSChannelTopicCommand: CSCommand {

    let channelName: String
    let topic: String

    // MARK: - Manual construction

    init(channelName: String, topic: String) {
        self.channelName = channelName
        self.topic = topic
    }

    // MARK: - CSCommand

    init?(description: String) {
        guard let (words, sentences) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 1) else {
            return nil
        }
        channelName = words[0]
        topic = sentences[0]
    }

    var description: String {
        return "CHANNELTOPIC \(channelName) \(topic)"
    }

    func execute(on server: LobbyServer) {

    }
}

/**
 Sent by a client when requesting to leave a channel.

 Note that when the client is disconnected, the client is automatically removed from all channels.
 */
struct CSLeaveCommand: CSCommand {

    let channelName: String

    // MARK: - Manual construction

    init(channelName: String) {
        self.channelName = channelName
    }

    // MARK: - CSCommand

    init?(description: String) {
        guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 0) else {
            return nil
        }
        channelName = words[0]
    }

    var description: String {
        return "LEAVE \(channelName)"
    }

    func execute(on server: LobbyServer) {
        
    }
}

/**
 Sent by the server to all clients in a channel. Used to broadcast messages in a channel.
 */
struct SCChannelMessageCommand: SCCommand {

    let channelName: String
    let message: String

    // MARK: - Manual construction

    init(channelName: String, message: String) {
        self.channelName = channelName
        self.message = message
    }

    // MARK: - SCCommand

    init?(description: String) {
        guard let (words, sentences) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 1) else {
            return nil
        }
        channelName = words[0]
        message = sentences[0]
    }

    var description: String {
        return "CHANNELMESSAGE \(channelName) \(message)"
    }

    func execute(on connection: Connection) {
        #warning("Incomplete implementation")
    }
}

/**
 Send a chat message to a specific channel. The client has to join the channel before it may use
 this command.
 */
struct CSSayCommand: CSCommand {

    let channelName: String
    let message: String

    // MARK: - Manual construction

    init(channelName: String, message: String) {
        self.channelName = channelName
        self.message = message
    }

    // MARK: - CSCommand

    init?(description: String) {
        guard let (words, sentences) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 1) else {
            return nil
        }
        channelName = words[0]
        message = sentences[0]
    }

    var description: String {
        return "SAY \(channelName) \(message)"
    }

    func execute(on server: LobbyServer) {

    }
}

/**
 Sent to all clients participating in a specific channel when one of the clients sent a chat message
 to it (including the author of the message).
 */
struct SCSaidCommand: SCCommand {

    let channelName: String
    let username: String
    let message: String

    // MARK: - Manual construction

    init(channelName: String, username: String, message: String) {
        self.channelName = channelName
        self.username = username
        self.message = message
    }

    // MARK: - SCCommand

    init?(description: String) {
        guard let (words, sentences) = try? wordsAndSentences(for: description, wordCount: 2, sentenceCount: 1) else {
            return nil
        }
        channelName = words[0]
        username = words[1]
        message = sentences[0]
    }

    var description: String {
        return "SAID \(channelName) \(username) \(message)"
    }

    func execute(on connection: Connection) {
		let channelID = connection.id(forChannelnamed: channelName)
		guard let channel = connection.channelList.items[channelID],
            let userID = connection.id(forPlayerNamed: username) else {
				return
		}
        channel.receivedNewMessage(ChatMessage(
            time: Date(),
            senderID: userID,
            senderName: username,
            content: message,
            isIRCStyle: false
        ))
    }
}

/**
 Sent by any client requesting to say something in a channel in "/me" IRC style. (The SAY command is
 used for normal chat messages.)
 */
struct CSSayExCommand: CSCommand {

    let channelName: String
    let message: String

    // MARK: - Manual construction

    init(channelName: String, message: String) {
        self.channelName = channelName
        self.message = message
    }

    // MARK: - CSCommand

    init?(description: String) {
        guard let (words, sentences) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 1) else {
            return nil
        }
        channelName = words[0]
        message = sentences[0]
    }

    var description: String {
        return "SAYEX \(channelName) \(message)"
    }

    func execute(on server: LobbyServer) {

    }
}

/**
 Sent by the server when a client said something using the SAYEX command.
 */
struct SCSaidExCommand: SCCommand {

    let channelName: String
    let username: String
    let message: String

    // MARK: - Manual construction

    init(channelName: String, username: String, message: String) {
        self.channelName = channelName
        self.username = username
        self.message = message
    }

    // MARK: - SCCommand

    init?(description: String) {
        guard let (words, sentences) = try? wordsAndSentences(for: description, wordCount: 2, sentenceCount: 1) else {
            return nil
        }
        channelName = words[0]
        username = words[1]
        message = sentences[0]
    }

    var description: String {
        return "SAIDEX \(channelName) \(username) \(message)"
    }

    func execute(on connection: Connection) {
		let channelID = connection.id(forChannelnamed: channelName)
        guard let channel = connection.channelList.items[channelID],
            let senderID = connection.id(forPlayerNamed: username) else {
            return
        }
        channel.receivedNewMessage(ChatMessage(
            time: Date(),
            senderID: senderID,
            senderName: username,
            content: message,
            isIRCStyle: true
        ))
    }
}

struct SCChannelCommand: SCCommand {
	
	let channelName: String
	let userCount: Int
	let topic: String?
	
	// MARK: - Manual Construction
	
	init(channelName: String, userCount: Int, topic: String?) {
		self.channelName = channelName
		self.userCount = userCount
		self.topic = topic
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, sentences) = try? wordsAndSentences(for: description, wordCount: 2, sentenceCount: 0, optionalSentences: 1),
		let userCount = Int(words[1]) else {
			return nil
		}
		channelName = words[0]
		self.userCount = userCount
		topic = sentences.count == 1 ? sentences[0] : nil
	}
	
	func execute(on connection: Connection) {
		#warning("todo")
	}
	
	var description: String {
		var string = "CHANNEL \(channelName) \(userCount)"
		if let topic = topic {
			string += " \(topic)"
		}
		return string
	}
}

struct SCEndOfChannelsCommand: SCCommand {
	
	// MARK: - Manual Construction
	
	init() {}
	
	// MARK: - SCCommand
	
	init?(description: String) {}
	
	func execute(on connection: Connection) {
		#warning("todo")
	}
	
	var description: String {
		return "ENDOFCHANNELS"
	}
}
