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


// TODO: - Add these functions as helpers on `Connection`

private func userIDs(for usernames: [String], on connection: Connection) -> [Int] {
    return usernames.map { userID(for: $0, on: connection) }
}

private func userID(for username: String, on connection: Connection) -> Int {
    let matches = connection.userList.items.filter({ $0.value.profile.username == username })
    // We can guarantee that there will be one and only one entry filtered for every
    // username; there will never be 0 or two.
    return matches.keys.first!
}

private func addClientsToChannel(named channelName: String, on connection: Connection, usernames: [String]) {
    guard let channel = connection.channelList.items[0] else { return }
    userIDs(for: usernames, on: connection).forEach(channel.userlist.addItemFromParent(id:))
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

    func execute(on connection: Connection) {
        addClientsToChannel(named: channelName, on: connection, usernames: clients)
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

    func execute(on connection: Connection) {
        addClientsToChannel(named: channelName, on: connection, usernames: [username])
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

    func execute(on connection: Connection) {
        guard let channel = connection.channelList.items[0] else { return }
        channel.userlist.removeItem(withID: userID(for: username, on: connection))
    }
}