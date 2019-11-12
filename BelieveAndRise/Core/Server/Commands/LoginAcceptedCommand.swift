//
//  LoginAcceptedCommand.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 15/7/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/**
 Sent as a response to the LOGIN command, if it succeeded. Next, the server will send much info
 about clients and battles:

 - multiple MOTD, each giving one line of the current welcome message
 - multiple ADDUSER, listing all users currently logged in
 - multiple BATTLEOPENED, UPDATEBATTLEINFO, detailing the state of all currently open battles
 - multiple JOINEDBATTLE, indiciating the clients present in each battle
 - multiple CLIENTSTATUS, detailing the statuses of all currently logged in users
 */
struct SCLoginAcceptedCommand: SCCommand {

    // MARK: - Properties

    let username: String

    // MARK: - Manual Construction

    init(username: String) {
        self.username = username
    }

    // MARK:  SCCommand

    init?(description: String) {
        guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 0) else {
            return nil
        }
        username = words[0]
    }

    var description: String {
        return "ACCEPTED \(username)"
    }

    func execute(on connection: Connection) {
        connection.windowController._window?.dismissPrompts()
    }
}
