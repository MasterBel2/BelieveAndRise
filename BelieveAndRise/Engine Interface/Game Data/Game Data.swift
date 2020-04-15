//
//  Game Data.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 15/4/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// A set of information fully describing how a game should be created by the SpringRTS engine.
struct GameData {
    /// The allyteams describing the teams and their alliances.
    ///
    /// Ally number is determined by position in the array. (I.e. Ally 0 is position 0, etc.)
    let allyTeams: [AllyTeam]
    /// The users who will be spectating the game.
    let spectators: [Player]
    /// The URL of the demo file to be replayed. If no demo file is required,
    let demoFile: URL?
    /// Information about the host.
    let hostConfig: HostConfig
    /// Information about how start positions are to be assigned to teams.
    let startConfig: StartConfig

    /// The name of the map.
    let mapName: String
    /// The unisync hash of the map.
    let mapHash: Int32

    // SpringLobby doesn't use this value, not sure what its role is.
//    let gameName: String
    /// The full name string of the game.
    let gameType: String
    /// ??? The unitsync hash of the game. ???
    let modHash: Int32
}
