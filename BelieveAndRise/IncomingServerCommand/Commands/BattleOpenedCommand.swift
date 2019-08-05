//
//  BattleOpenedCommand.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 30/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

enum ParsingError: Error {
    case noCharactersRemaining
}

// WIP

func wordsAndSentences(for commandPayload: String, wordCount: Int, sentenceCount: Int) throws -> (words: [String], sentences: [String]) {
    var mutableString = commandPayload
    var buffer = [Character]()
    var words = [String]()
    var sentences = [String]()

    while words.count < wordCount {
        guard let character = mutableString.first else {
            words.append(String(buffer))
            return (words: words, sentences: sentences)
        }
        if character == " " {
            words.append(String(buffer))
            buffer = []
        } else {
            buffer.append(character)
        }

        mutableString = String(mutableString.dropFirst())
    }

    // Sentences are separated by a tab character. There is no tab character before the first sentence

    while sentences.count < sentenceCount {
        guard let character = mutableString.first else {
            sentences.append(String(buffer))
            return (words: words, sentences: sentences)
        }
        if character == "\t" {
            sentences.append(String(buffer))
            mutableString = String(mutableString.dropFirst())
            buffer = []
        } else {
            buffer.append(character)
            mutableString = String(mutableString.dropFirst())
        }
    }

    if mutableString != "" {
        print("Command payload incorrectly parsed: remaning text was \"\(mutableString)\"")
    }
    return (words: words, sentences: sentences)
}

/// See https://springrts.com/dl/LobbyProtocol/ProtocolDescription.html#BATTLEOPENED:server
struct BattleOpenedCommand: IncomingServerCommand {
    private let battleID: Int
    private let battle: Battle
    weak var delegate: IncomingServerCommandDelegate?
    
    // MARK: - Lifecycle
    
    init?(server: TASServer, payload: String, dataSource: IncomingServerCommandDataSource, delegate: IncomingServerCommandDelegate) {
        do {
            // 10 words:
            // battleID type natType founder ip port maxPlayers passworded rank mapHash

            // 6 sentences:
            // {engineName} {engineVersion} {map} {title} {gameName} {channel}

            let (words, sentences) = try wordsAndSentences(for: payload, wordCount: 10, sentenceCount: 6)

            guard let battleID = Int(words[0]),
                let port = Int(words[5]),
                let maxPlayers = Int(words[6]),
                let rank = Int(words[8]),
                let mapHash = Int(words[9])
                else {
                    return nil
            }

            let isReplay = words[1] == "1"

            let natType: NATType
            switch words[2] {
            case "1":
                natType = .holePunching
            case "2":
                natType = .fixedSourcePorts
            default:
                natType = .none
            }

            let passworded = words[7] == "1"

            let ip = words[4]
            let founder = words[3]
            #warning("Hardcoded incorrect value")
            let founderID = 0

            // Store properties

            self.delegate = delegate
            self.battleID = battleID
            self.battle = Battle(
                isReplay: isReplay,
                natType: natType,
                founder: founder,
                founderID: founderID,
                ip: ip,
                port: port,
                maxPlayers: maxPlayers,
                passworded: passworded,
                rank: rank,
                mapHash: mapHash,
                engineName: sentences[0],
                engineVersion: sentences[1],
                mapName: sentences[2],
                title: sentences[3],
                gameName: sentences[4],
                channel: sentences[5]
            )
        } catch {
            print(error)
            return nil
        }
    }
    
    // MARK: - Behaviour
    
    func execute() {
        delegate?.createBattle(battle, identifiedBy: battleID)
    }
    
}
