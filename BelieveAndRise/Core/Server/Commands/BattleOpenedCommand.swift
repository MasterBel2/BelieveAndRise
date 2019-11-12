//
//  BattleOpenedCommand.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 30/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/// See https://springrts.com/dl/LobbyProtocol/ProtocolDescription.html#BATTLEOPENED:server
struct BattleOpenedCommand: SCCommand {
    private let battleID: Int

    private let isReplay: Bool
    private let natType: NATType
    private let founder: String
    private let ip: String
    private let port: Int
    private let maxPlayers: Int
    private let passworded: Bool
    private let rank: Int
    private let mapHash: Int

    private let engineName: String
    private let engineVersion: String
    private let mapName: String
    private let title: String
    private let gameName: String
    private let channel: String

    // MARK: - Lifecycle
    
    init?(description: String) {
        do {
            // 10 words:
            // battleID type natType founder ip port maxPlayers passworded rank mapHash

            // 6 sentences:
            // {engineName} {engineVersion} {map} {title} {gameName} {channel}

            let (words, sentences) = try wordsAndSentences(for: description, wordCount: 10, sentenceCount: 6)

            guard let battleID = Int(words[0]),
                let port = Int(words[5]),
                let maxPlayers = Int(words[6]),
                let rank = Int(words[8]),
                let mapHash = Int(words[9])
                else {
                    return nil
            }
            self.battleID = battleID
            self.port = port
            self.maxPlayers = maxPlayers
            self.rank = rank
            self.mapHash = mapHash

            isReplay = words[1] == "1"

            switch words[2] {
            case "1":
                natType = .holePunching
            case "2":
                natType = .fixedSourcePorts
            default:
                natType = .none
            }

            passworded = words[7] == "1"

            ip = words[4]
            founder = words[3]

            engineName = sentences[0]
            engineVersion = sentences[1]
            mapName = sentences[2]
            title = sentences[3]
            gameName = sentences[4]
            channel = sentences[5]
        } catch {
            print(error)
            return nil
        }
    }
    
    // MARK: - Behaviour
    
    func execute(on connection: Connection) {
        guard let founderID = connection.id(forPlayerNamed: founder) else {
            fatalError("Could not find battle host with username \(founder)")
        }
        let battle = Battle(
            serverUserList: connection.userList,
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
            engineName: engineName,
            engineVersion: engineVersion,
            mapName: mapName,
            title: title,
            gameName: gameName,
            channel: channel
        )

        connection.battleList.addItem(battle, with: battleID)
        print("battleCount: \(connection.battleList.itemCount)")
    }

    // MARK: - String representation

    var description: String {
        #warning("TODO")
        return ""
    }
}
