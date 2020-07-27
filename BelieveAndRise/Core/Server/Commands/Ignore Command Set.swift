//
//  Ignore Command Set.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 4/7/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

///

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

    func execute(on client: Client) {
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

    func execute(on client: Client) {
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

    func execute(on client: Client) {
        #warning("todo")
    }

    var description: String {
        return "IGNORELISTBEGIN"
    }
}

struct SCIgnoreListCommand: SCCommand {

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

    func execute(on client: Client) {
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

struct SCCIgnoreListEndCommand: SCCommand {

    // MARK: - Manual Construction

    init() {}

    // MARK: - SCCommand

    init?(description: String) {}

    func execute(on client: Client) {
        #warning("todo")
    }

    var description: String {
        return "IGNORELISTEND"
    }
}
