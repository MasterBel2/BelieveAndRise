//
//  SCClientsCommand.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 2/9/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

// Contains the following commands:
// - SCClientsCommand
// - SCJoinedCommand
// - SCLeftCommand

private func addUsersToChannel(named channelName: String, on client: Client, usernames: [String]) {
    guard let channel = client.channelList.items[client.id(forChannelnamed: channelName)] else {
		return
	}
	
	for username in usernames {
		guard let id = client.id(forPlayerNamed: username) else {
			return
		}
		channel.userlist.addItemFromParent(id: id)
	}
}

// MARK: - Functions

/**
 Sent to a client who just joined the channel. This command informs the client of the list of
 users present in the channel, including the client itself.

 This command is always sent (to a client joining a channel), and the list it conveys includes
 the newly joined client. It is sent after all the CLIENTSFROM commands. Once CLIENTS has been
 processed, the joining client has been informed of the full list of other clients and bridged
 clients currently present in the joined channel.
 */
struct SCClientsCommand: SCCommand {

    let channelName: String
    let clients: [String]

    // MARK: - Manual construction

    init(channelName: String, clients: [String]) {
        self.channelName = channelName
        self.clients = clients
    }

    // MARK: - SCCommand

    init?(description: String) {
        guard let (words, sentences) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 1) else {
            return nil
        }
        channelName = words[0]
        clients = sentences[0].components(separatedBy: " ")
    }

    var description: String {
        return "CLIENTS \(channelName) \(clients.joined(separator: " "))"
    }

    func execute(on client: Client) {
        addUsersToChannel(named: channelName, on: client, usernames: clients)
    }
}

/**
 Sent to all clients in a channel (except the new client) when a new user joins the channel.
 */
struct SCJoinedCommand: SCCommand {

    let channelName: String
    let username: String

    // MARK: - Manual construction

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

    var description: String {
        return "JOINED \(channelName) \(username)"
    }

    func execute(on client: Client) {
        addUsersToChannel(named: channelName, on: client, usernames: [username])
    }
}

/**
 Sent by the server to inform a client, present in a channel, that another user has left that
 channel.
 */
struct SCLeftCommand: SCCommand {

    let channelName: String
    let username: String
    let reason: String

    // MARK: - Manual construction

    init(channelName: String, username: String, reason: String) {
        self.channelName = channelName
        self.username = username
        self.reason = reason
    }

    // MARK: - SCCommand

    init?(description: String) {
        guard let (words, sentences) = try? wordsAndSentences(for: description, wordCount: 2, sentenceCount: 1) else {
            return nil
        }
        channelName = words[0]
        username = words[1]
        reason = sentences[0]
    }

    var description: String {
        return "LEFT \(channelName) \(username) \(reason)"
    }

    func execute(on client: Client) {
		let channelID = client.id(forChannelnamed: channelName)
        guard let channel = client.channelList.items[channelID],
			let id = client.id(forPlayerNamed: username)
			else {
				return
		}
		channel.userlist.removeItem(withID: id)
    }
}
