//
//  BattleOpenedCommand.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 30/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

struct BattleOpenedCommand: IncomingServerCommand {
    private let battleID: Int
    private let battle: Battle
    weak var delegate: IncomingServerCommandDelegate?
    
    // MARK: - Lifecycle
    
    init?(server: TASServer, arguments: [String], dataSource: IncomingServerCommandDataSource, delegate: IncomingServerCommandDelegate) {
        guard arguments.count == 12,
            // First argument is command
            let battleID = Int(arguments[1]),
            let port = Int(arguments[6]),
            let maxPlayers = Int(arguments[7]),
            let rank = Int(arguments[9]),
            let mapHash = Int(arguments[10])
            else {
                return nil
        }
        let isReplay = arguments[2] == "1"
        
        let natType: NATType
        switch arguments[3] {
        case "1":
            natType = .holePunching
        case "2":
            natType = .fixedSourcePorts
        default:
            natType = .none
        }
        
        let passworded = arguments[8] == "1"
        
        let ip = arguments[5]
        let founder = arguments[4]
        #warning("Hardcoded incorrect value")
        let founderID = 0
        
        // sentences
        
        let sentences = arguments.last!.components(separatedBy: "/t")
        
        // store properties
        
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
            gameName: sentences[4]
            
        )
    }
    
    // MARK: - Behaviour
    
    func execute() {
        guard let delegate = delegate else {
            return
        }
        
        delegate.createBattle(battle, identifiedBy: battleID)
    }
    
}
