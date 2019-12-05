//
//  GameTypes.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 5/12/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/// A structure that encapsulates information about the replay to be hosted by the spring instance to be written in a launchscript
struct Replay {
    let fileName: String
    let date: String
    let map: String
    let fileExtension: String
    let engineVersion: String

    init() {// This initialiser assumes that the map name has no underscores.
            // That will not always be the case. Please change it so that
            // it can grab the data from inside the file. This first init()
            // will end up being obsolete anyway. The second one you really
            // have to worry about, though.
        fileName = "Date_160627_Name Of Map_103.sdfz"
        let array = fileName.components(separatedBy: "_")
        self.date = array[0]
        self.map = array[2]
        let array2 = array[3].components(separatedBy: ".")
        self.engineVersion = array2[0]
        self.fileExtension = array2[1]
    }

    init(with data: NSData, from fileName: String) {
        let string = String(describing: data)
        self.fileName = fileName
        let array = fileName.components(separatedBy: "_")
        self.date = array[0]
        self.map = array[2]
        let array2 = array[3].components(separatedBy: ".")
        self.engineVersion = array2[0]
        self.fileExtension = array2[1]


        // I know this is a copout, but that's how it'll be for now. Okay? Good.
    }
}

///
enum StartPositionType: Int {
    case fixed = 0
    case random = 1
    case chooseInGame = 2
    case chooseBeforeGame = 3
}

/// A structure that encapsulates information about the game to be hosted by the spring instance to be written in a launchscript
struct HostedGame {
    // [GAME] {
    let myPlayerName: String
    let mapName: String // Name of the file
    let mapHash: Int32
    let gameName: String
    let modHash: Int32
    let gameType: String // either primary mod NAME, rapid tag name or archive name
    let gameStartDelay: Int // optional, in seconds, (unsigned int), default: 4
    let startPosType: StartPositionType // 0 fixed, 1 random, 2 choose in game, 3 choose before game (see StartPosX)

    let doRecordDemo: Bool // when finally input, 0 for false and 1 for true

    let hostType: String
    let hostIp: String //
    let hostPort: Int //
    let isHost: Bool = true // 1 for true, 0 for false

    let autohostAccountID: Int
    let autohostCountryCode: CountryCode
    let autohostName: String
    let autohostRank: String

    let demoFile: String

    // [PLAYER0] {
    let players: [Player]
    // }

    let ais: [AI]
    // [AI0] {…} [AIX] {

    let teams: [Team]

    let allyTeams: [AllyTeam]

    // TODO: -- Restrictions
    let restrictions: [Restriction]

    let modOptions: [ModOption]
}

/// A structure that encapsulates information about a unit restriction to be written in a launchscript
struct Restriction {}

/// A structure that encapsulates information about an AI to be written in a launchscript
struct AI {
    let name: String
    // The number of the player the AI is associated with
    let host: Int
    let isFromDemo: Bool
    let team: Int
    let shortName: String
    let version: String
}

/// A structure that encapsulates information about a player to be written in a launchscript
struct Player {
    // [PLAYER0] {
    let username: String
    let password: String //
    let isSpectator: Bool // 1 for true, 0 for false
    let team: Int // The team number controlled by the player
    let isFromDemo: Bool //
    let countryCode: CountryCode // Country code of the player.
    let rank: Int
    let skill: String
    // }
}

/// A structure that encapsulates information about a team to be written in a launchscript
struct Team {
    // [TEAM0] {
    let leader: Int // Player number of the leader
    let allyTeamNumber: Int
    let rgbColor: (r: Float, g: Float, b: Float) // r g b in range 0 to 1
    let side: String // Arm/Core; other sides possible with mods other than BA
    let handicap = "0" // Deprecated, see advantage; but is -100 to 100 - % resource income bonus

    let advantage: Int // Advantage factor (meta value). Currently only affects incomeMultiplier (below). Valid: [-1.0, FLOAT_MAX]
    let incomeMultiplier: Int // multiplication factor for collected resources. valid [0.0, FLOAT_MAX]
    let startPosX: Int // Use these in combination with StartPosType = 3
    let startPosZ: Int // Range is in map coordinates as returned by UnitSync
    let luaAI: String = "" // name of the LuaAI that controls this team
    // Either a [PLAYER] or an [AI] is controlling this team, or a LuaAI is set
    // }
}

/// A structure that encapsulates information about an allyteam to be written in a launchscript
struct AllyTeam {
    var numAllies: Int {
        return allies.count
    }
        // idk
    let allies: [String] = [""] // means that this team is allied with the other, not necesarily the reverse (just put each allied allyteam in the array and you can cycle through them, ok?)
    let startRectTop: String   // Use these in combination with StartPosType=2
    let startRectLeft: String   //   (ie. select in map)
    let startRectBottom: String // range is 0-1: 0 is left or top edge,
    let startRectRight: String  //   1 is right or bottom edge
}

/// A structure that encapsulates mod option information to be written in a launchscript
struct ModOption {
    let name: String
    var value: String
}
