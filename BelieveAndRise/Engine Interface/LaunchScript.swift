//
//  LaunchScript.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 28/7/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// A namespace for launch script related objects.
enum LaunchScript {

    /// Describes a section of a launch script.
    struct WritableScriptSection {
        let identifier: ScriptSections.Section
        let nestedSections: [WritableScriptSection]
        let arguments: [String : String]
        var description: String {
            return """
            [\(identifier.description.lowercased())]
            {
            \(nestedSections.sorted(by: { $0.identifier.description < $1.identifier.description }).map({ $0.description }).joined(separator: "\n"))
            \(arguments.map({ "\($0.key.lowercased())=\($0.value);"}).sorted().joined(separator: "\n"))
            }
            """
        }
    }

    /// Describes a script that connects to a remote server.
    struct ClientSpecification: LaunchScriptConvertible {
        let ip: String
        let port: Int
        let username: String
        let scriptPassword: String

        func launchScript(shouldRecordDemo: Bool) -> String {
            let gameSection = WritableScriptSection(
                identifier: .game,
                nestedSections: [],
                arguments: [
                    "HostIP" : ip,
                    "HostPort" : String(port),
                    "MyPlayerName" : username,
                    "MyPasswd" : scriptPassword,
                    "DoRecordDemo": String(shouldRecordDemo ? 1 : 0),
                    "IsHost" : String(0)
                ]
            )
            return gameSection.description
        }
    }

    /// A structure that encapsulates information about the game to be hosted by the spring instance to be written in a launchscript
    ///
    /// Documentation has been copied from the [SpringRTS wiki](https://springrts.com/wiki/Script.txt).
    struct HostedGame {
        var stringValue: String {
            var gameSection: [String : String] = [:]

            gameSection["MyPlayerName"] = myPlayerName
            gameSection["MapName"] = mapName
            if let mapHash = mapHash { gameSection["MapHash"] = String(mapHash) }
            if let modHash = modHash { gameSection["ModHash"] = String(modHash) }
            gameSection["GameType"] = gameType
            if let gameStartDelay = gameStartDelay { gameSection["GameStartDelay"] = String(gameStartDelay) }
            gameSection["StartPosType"] = String(startPositionType.rawValue)

            gameSection["DoRecordDemo"] = String(doRecordDemo ? 1 : 0)

            gameSection["HostType"] = hostType
            gameSection["HostIp"] = hostIp
            gameSection["HostPort"] = String(hostPort)
            gameSection["IsHost"] = String(isHost ? 1 : 0)

            if let autohost = autohost {
                if let id = autohost.id { gameSection["AutoHostAccountId"] = String(id) }
                gameSection["AutoHostName"] = autohost.name
                if let countryCode = autohost.countryCode { gameSection["AutoHostCountryCode"] = countryCode.rawValue }
                gameSection["AutoHostPort"] = String(autohost.port)
                if let rank = autohost.rank { gameSection["AutoHostRank"] = String(rank) }
            }

            if let demoFile = demoFile { gameSection["DemoFile"] = demoFile }

            gameSection["Numplayers"] = String(players.count)
            gameSection["NumTeams"] = String(teams.count)
            gameSection["NumAllyTeams"] = String(allyTeams.count)
            gameSection["NumRestrictions"] = String(restrictions.count)

            let playerSections = players.enumerated().map({ WritableScriptSection(identifier: .player(number: $0.offset), nestedSections: [], arguments: $0.element.description) })
            let teamSections = teams.enumerated().map({ WritableScriptSection(identifier: .team(number: $0.offset), nestedSections: [], arguments: $0.element.description) })
            let allyTeamSections = allyTeams.enumerated().map({ WritableScriptSection(identifier: .allyteam(number: $0.offset), nestedSections: [], arguments: $0.element.description) })
            let aiSections = ais.enumerated().map({ WritableScriptSection(identifier: .ai(number: $0.offset), nestedSections: [], arguments: $0.element.description) })

            var formattedRestrictions: [String : String] = [:]
            restrictions.enumerated().forEach({
                formattedRestrictions["Limit\($0.offset)"] = String($0.element.value)
                formattedRestrictions["Unit\($0.offset)"] = String($0.element.key)
            })

            let writableGameSection = WritableScriptSection(
                identifier: .game,
                nestedSections: [
                    WritableScriptSection(identifier: .restrictions, nestedSections: [], arguments: formattedRestrictions),
                    WritableScriptSection(identifier: .mapOptions, nestedSections: [], arguments: mapOptions),
                    WritableScriptSection(identifier: .modOptions, nestedSections: [], arguments: modOptions)
                ] + playerSections + teamSections + allyTeamSections + aiSections,
                arguments: gameSection
            )
            return writableGameSection.description
        }

        // [GAME] {
        let myPlayerName: String
        let mapName: String // Name of the file
        let mapHash: UInt32?
        // SpringLobby doesn't use this value
        //        let gameName: String
        let modHash: UInt32?
        let gameType: String // either primary mod NAME, rapid tag name or archive name
        let gameStartDelay: Int? // optional, in seconds, (unsigned int), default: 4
        let startPositionType: StartPositionType // 0 fixed, 1 random, 2 choose in game, 3 choose before game (see StartPosX)

        let doRecordDemo: Bool // when finally input, 0 for false and 1 for true

        let hostType: String
        let hostIp: String //
        let hostPort: Int //
        let isHost: Bool = true // 1 for true, 0 for false


        struct Autohost {
            let id: Int?
            let countryCode: CountryCode?
            let name: String
            let rank: Int?
            let port: Int
        }

        let autohost: Autohost?

        let demoFile: String?

        // [PLAYER0] {
        let players: [Player]
        // }

        let ais: [AI]
        // [AI0] {…} [AIX] {

        let teams: [Team]

        let allyTeams: [AllyTeam]

        // Unit : Max #
        let restrictions: [String : Int]

        let modOptions: [String : String]
        let mapOptions: [String : String]
    }

    /// A structure that encapsulates information about an AI to be written in a launchscript
    struct AI {
        let name: String
        /// The number of the player the AI is associated with
        let host: Int
        let isFromDemo: Bool
        let team: Int
        let shortName: String
        let version: String

        var description: [String : String] {
            return [
                "Name" : name,
                "Host" : String(host),
                "IsFromDemo" : String(isFromDemo ? 1 : 0),
                "Team" : String(team),
                "ShortName" : shortName,
                "Version" : version
            ]
        }
    }

    /// A structure that encapsulates information about a player to be written in a launchscript
    struct Player {
        // [PLAYER0] {
        let username: String
        let accountID: Int?
        let password: String? //
        let countryCode: CountryCode? // Country code of the player.
        let isFromDemo: Bool //

        let rank: Int?
        let skill: String?

        let team: Int? // The team number controlled by the player
        let isSpectator: Bool // 1 for true, 0 for false
        // }

        var description: [String : String] {
            var temp: [String : String] = [
                "Name" : username,
                "IsFromDemo" : String(isFromDemo ? 1 : 0),
                "Spectator" : String(isSpectator ? 1 : 0),
            ]
            if let accountID = accountID { temp["AccountId"] = String(accountID) }
            if let password = password { temp["Password"] = password }
            if let team = team { temp["Team"] = String(team) }
            if let rank = rank { temp["Rank"] = String(rank) }
            if let skill = skill { temp["Skill"] = skill }
            if let countryCode = countryCode { temp["CountryCode"] = countryCode.rawValue }
            return temp
        }
    }

    /// A structure that encapsulates information about a team to be written in a launchscript
    struct Team {
        // [TEAM0] {
        let leader: Int // Player number of the leader
        let allyTeamNumber: Int
        let rgbColor: (red: Float, green: Float, blue: Float) // r g b in range 0 to 1
        let side: String? // Arm/Core; other sides possible with mods other than BA
        let handicap: Int = 0 // Deprecated, see advantage; but is -100 to 100 - % resource income bonus

        let advantage: Float? // Advantage factor (meta value). Currently only affects incomeMultiplier (below). Valid: [-1.0, FLOAT_MAX]
        let incomeMultiplier: Float? // multiplication factor for collected resources. valid [0.0, FLOAT_MAX]
        let startPosX: Int? // Use these in combination with StartPosType = 3
        let startPosZ: Int? // Range is in map coordinates as returned by UnitSync
        let luaAI: String? // name of the LuaAI that controls this team
        // Either a [PLAYER] or an [AI] is controlling this team, or a LuaAI is set
        // }

        var description: [String : String] {
            var temp: [String : String] = [
                "TeamLeader" : String(leader),
                "AllyTeam" : String(allyTeamNumber),
                "RGBColor" : "\(rgbColor.red) \(rgbColor.green) \(rgbColor.blue)",
                "Handicap" : String(handicap),

            ]
            if let side = side { temp["Side"] = side }
            if let advantage = advantage { temp["Advantage"] = String(advantage) }
            if let incomeMultiplier = incomeMultiplier { temp["IncomeMultiplier"] = String(incomeMultiplier) }
            if let startPosX = startPosX { temp["StartPosX"] = String(startPosX) }
            if let startPosZ = startPosZ { temp["StartPosZ"] = String(startPosZ) }
            if let luaAI = luaAI { temp["LuaAI"] = luaAI }
            return temp
        }
    }

    /// A structure that encapsulates information about an allyteam to be written in a launchscript
    struct AllyTeam {
        var numAllies: Int {
            return allies.count
        }
        // idk
        let allies: [String] = [] // means that this team is allied with the other, not necesarily the reverse (just put each allied allyteam in the array and you can cycle through them, ok?)
        let startRectTop: String?   // Use these in combination with StartPosType=2
        let startRectLeft: String?   //   (ie. select in map)
        let startRectBottom: String? // range is 0-1: 0 is left or top edge,
        let startRectRight: String?  //   1 is right or bottom edge

        var description: [String : String] {
            var temp: [String : String] = [
                "NumAllies" : String(numAllies)
            ]
            if let startRectTop = startRectTop { temp["StartRectTop"] = startRectTop }
            if let startRectBottom = startRectBottom { temp["StartRectBottom"] = startRectBottom }
            if let startRectRight = startRectRight { temp["StartRectRight"] = startRectRight }
            if let startRectLeft = startRectLeft { temp["StartRectLeft"] = startRectLeft }
            return temp
        }
    }

    enum StartPositionType: Int {
        case fixed = 0
        case random = 1
        case chooseInGame = 2
        case chooseBeforeGame = 3
    }
}
