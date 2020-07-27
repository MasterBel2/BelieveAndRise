//
//  GameSpecification.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 15/4/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// A set of information fully describing how a game should be created by the SpringRTS engine.
struct GameSpecification: LaunchScriptConvertible {
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
    let mapHash: UInt32?

    // SpringLobby doesn't use this value, not sure what its role is.
    //    let gameName: String
    /// The full name string of the game.
    let gameType: String
    /// ??? The unitsync hash of the game. ???
    let modHash: UInt32?

    /// An optional values specifying the number of seconds by which to delay the start of the game after all players are ingame/ready.
    let gameStartDelay: Int?

    let mapOptions: [String : String]
    let modOptions: [String : String]
    /// Restricts number of the given units (specified by key) to the given value.
    let restrictions: [String : Int]

    init(allyTeams: [AllyTeam], spectators: [Player], demoFile: URL?, hostConfig: HostConfig, startConfig: StartConfig, mapName: String, mapHash: UInt32?, gameType: String, modHash: UInt32?, gameStartDelay: Int?, mapOptions: [String : String], modOptions: [String : String], restrictions: [String : Int]) {
        self.allyTeams = allyTeams
        self.spectators = spectators
        self.demoFile = demoFile
        self.hostConfig = hostConfig
        self.startConfig = startConfig
        self.mapName = mapName
        self.mapHash = mapHash
        self.gameType = gameType
        self.modHash = modHash
        self.gameStartDelay = gameStartDelay
        self.mapOptions = mapOptions
        self.modOptions = modOptions
        self.restrictions = restrictions
    }

    func launchScript(shouldRecordDemo: Bool) -> String {
        let startPositions: [Int : StartConfig.Coordinate]?
        let startBoxes: [Int: StartBox]?
        let startPositionType: LaunchScript.StartPositionType

        switch startConfig {
        case .chooseBeforeGame(let _startPositions):
            startPositions = _startPositions
            startPositionType = .chooseBeforeGame
            startBoxes = nil
        case .fixed:
            startPositionType = .fixed
            startBoxes = nil
            startPositions = nil
        case .random:
            startPositionType = .random
            startBoxes = nil
            startPositions = nil
        case .chooseInGame(let _startBoxes):
            startBoxes = _startBoxes
            startPositions = nil
            startPositionType = .chooseInGame
        }

        let teams = allyTeams.reduce([], { $0 + $1.teams })
        let indexedPlayers = teams.reduce([], { (partialResult, team) in partialResult + team.players.map({(teamID: team.scriptID, player: $0)})})
        let sortedIndexedPlayers = indexedPlayers.sorted(by: { $0.1.scriptID < $1.1.scriptID })
        let scriptPlayers = sortedIndexedPlayers.map({ (teamID: Int, player: Player) -> LaunchScript.Player in
            return LaunchScript.Player(
                username: player.username,
                accountID: player.userID,
                password: player.scriptPassword,
                countryCode: player.countryCode,
                isFromDemo: player.isFromDemo,
                rank: player.rank,
                skill: player.skill,
                team: teamID,
                isSpectator: false
            )
        }) + spectators.sorted(by: { $0.scriptID < $1.scriptID }).map({ (spectator: Player) -> LaunchScript.Player in
            return LaunchScript.Player(
                username: spectator.username,
                accountID: spectator.userID,
                password: spectator.scriptPassword,
                countryCode: spectator.countryCode,
                isFromDemo: spectator.isFromDemo,
                rank: spectator.rank,
                skill: spectator.skill,
                team: nil,
                isSpectator: true
            )
        })
        let indexedAIs = teams.reduce([], { (partialResult, team) in partialResult + team.ais.map({(teamID: team.scriptID, ai: $0)})})
        let scriptAIs = indexedAIs.sorted(by: {$0.ai.scriptID < $1.ai.scriptID }).map({ (teamID, ai) in
            return LaunchScript.AI(
                name: ai.name,
                host: ai.hostID,
                isFromDemo: ai.isFromDemo,
                team: teamID,
                shortName: ai.shortName,
                version: ai.version
            )
        })
        let indexedTeams = allyTeams.reduce([], { (partialResult, allyTeam) in partialResult + allyTeam.teams.map({(allyTeamID: allyTeam.scriptID, team: $0)})})
        let scriptTeams = indexedTeams.sorted(by: { $0.team.scriptID < $1.team.scriptID }).map({ (allyTeamID: Int, team: Team) -> LaunchScript.Team in
            let red =   Float((team.color & 0x00FF0000) >> 16) / 255
            let green = Float((team.color & 0x0000FF00) >>  8) / 255
            let blue =  Float((team.color & 0x000000FF)      ) / 255
            return LaunchScript.Team(
                leader: team.leader,
                allyTeamNumber: allyTeamID,
                rgbColor: (red, green, blue),
                side: team.side,
                advantage: team.advantage,
                incomeMultiplier: team.incomeMultiplier,
                startPosX: startPositions?[team.scriptID]?.x,
                startPosZ: startPositions?[team.scriptID]?.z,
                luaAI: team.luaAI
            )
        })
        let scriptAllyTeams = allyTeams.sorted(by: { $0.scriptID < $1.scriptID }).map({ (allyTeam: AllyTeam) -> LaunchScript.AllyTeam in
            let left: String?
            let right: String?
            let bottom: String?
            let top: String?
            if let startbox = startBoxes?[allyTeam.scriptID] {
                top    = String(Float(startbox.y) / 200)
                left   = String(Float(startbox.x) / 200)
                right  = String(Float(startbox.x + startbox.width) / 200)
                bottom = String(Float(startbox.y + startbox.height) / 200)
            } else {
                left = nil; right = nil; bottom = nil; top = nil
            }
            return LaunchScript.AllyTeam(
                startRectTop: top,
                startRectLeft: left,
                startRectBottom: bottom,
                startRectRight: right
            )
        })

        let hostType: String
        let autohost: LaunchScript.HostedGame.Autohost?
        switch hostConfig.type {
        case .autohost(let (programName, port)):
            hostType = programName
            autohost = LaunchScript.HostedGame.Autohost(
                id: hostConfig.userID,
                countryCode: hostConfig.countryCode,
                name: hostConfig.username,
                rank: hostConfig.rank,
                port: port
            )
        case .user(let lobbyName):
            hostType = lobbyName
            autohost = nil
        }

        return LaunchScript.HostedGame(
            myPlayerName: hostConfig.username,
            mapName: mapName,
            mapHash: mapHash,
            modHash: modHash,
            gameType: gameType,
            gameStartDelay: gameStartDelay,
            startPositionType: startPositionType,
            doRecordDemo: shouldRecordDemo,
            hostType: hostType,
            hostIp: hostConfig.address.location,
            hostPort: hostConfig.address.port,
            autohost: autohost,
            demoFile: demoFile?.path,
            players: scriptPlayers,
            ais: scriptAIs,
            teams: scriptTeams,
            allyTeams: scriptAllyTeams,
            restrictions: restrictions,
            modOptions: modOptions,
            mapOptions: mapOptions
        ).stringValue
    }

    init(sections: ScriptSections, fromDemoFileAt demoFileURL: URL? = nil) throws {
        let (spectators, players) = try GameSpecification.playersDescribed(by: sections, isFromDemo: demoFileURL == nil)
        allyTeams = try GameSpecification.allyTeamsDescribed(by: sections, players: players, ais: [:])


        hostConfig = try GameSpecification.hostSettings(describedBy: sections, players: allyTeams.reduce([], {$0 + $1.teams}).reduce([], {$0 + $1.players}) + spectators)
        startConfig = try GameSpecification.startSettings(describedBy: sections, allyTeamCount: allyTeams.count, teamCount: allyTeams.reduce(0, { $0 + $1.teams.count }))
        mapName = try sections.game(key: "MapName")
        mapHash = try? UInt32(sections.keyedInteger(for: "MapHash", from: .game))
        gameType = try sections.game(key: "GameType")
        modHash = try? UInt32(sections.keyedInteger(for: "ModHash", from: .game))

        gameStartDelay = try? sections.keyedInteger(for: "GameStartDelay", from: .game)

        self.spectators = spectators
        self.demoFile = demoFileURL

        self.modOptions = (try? sections.sectionValues(.modOptions)) ?? [:]
        self.mapOptions = (try? sections.sectionValues(.mapOptions)) ?? [:]

        var formattedRestrictions: [String : Int] = [:]
        let expectedRestrictionsCount = try sections.keyedInteger(for: "NumRestrictions", from: .game)
        try (0..<expectedRestrictionsCount).forEach({
            let limit = try sections.keyedInteger(for: "Limit\($0)", from: .restrictions)
            let unit = try sections.keyedString(for: "Unit\($0)", from: .restrictions)
            formattedRestrictions[unit] = limit
        })
        restrictions = formattedRestrictions
    }

    static func hostSettings(describedBy sections: ScriptSections, players: [Player]) throws -> HostConfig {
        let serverAddress = ServerAddress(
            location: try sections.game(key: "HostIp"),
            port: try sections.keyedInteger(for: "HostPort", from: .game)
        )

        if let hostName = try? sections.game(key: "autohostname"),
            let hostPort = try? sections.keyedInteger(for: "AutoHostPort", from: .game) {
            let hostRank = try? sections.keyedInteger(for: "AutoHostRank", from: .game)
            let userID = try? sections.keyedInteger(for: "AutoHostAccountId", from: .game)
            let countryCode: CountryCode?
            if let countryCodeString = try? sections.game(key: "AutoHostCountryCode") {
                countryCode = CountryCode(rawValue: countryCodeString.uppercased())
            } else { countryCode = nil }
            return HostConfig(
                userID: userID,
                username: hostName,
                type: .autohost((programName: (try? sections.keyedString(for: "HostType", from: .game)) ?? "Unknown", port: hostPort)),
                address: serverAddress,
                rank: hostRank,
                countryCode: countryCode
            )
        }
        let name = try sections.game(key: "MyPlayerName")
        let player = players.filter({$0.username == name }).first
        return HostConfig(
            userID: player?.userID,
            username: name,
            type: .user(lobbyName: (try? sections.game(key: "HostType")) ?? "Unknown"),
            address: serverAddress,
            rank: player?.rank,
            countryCode: player?.countryCode
        )
    }

    static func startSettings(describedBy sections: ScriptSections, allyTeamCount: Int, teamCount: Int) throws -> StartConfig {
        let startpostype = try sections.keyedInteger(for: "StartPosType", from: .game)

        switch startpostype {
        case 0: // Fixed
            return .fixed
        case 1: // Random
            return .random
        case 2: // Choose in game
            var startBoxes: [Int : StartBox] = [:]
            (0..<allyTeamCount).forEach({ (allyTeamNumber: Int) -> Void in
                if let left = try? Int(sections.keyedFloat(for: "StartRectLeft", from: .allyteam(number: allyTeamNumber)) * 200),
                    let right = try? Int(sections.keyedFloat(for: "StartRectRight", from: .allyteam(number: allyTeamNumber)) * 200),
                    let top = try? Int(sections.keyedFloat(for: "StartRectTop", from: .allyteam(number: allyTeamNumber)) * 200),
                    let bottom = try? Int(sections.keyedFloat(for: "StartRectBottom", from: .allyteam(number: allyTeamNumber)) * 200) {
                    startBoxes[allyTeamNumber] = StartBox(
                        x: left,
                        y: top,
                        width: right - left,
                        height: bottom - top
                    )
                }
            })
            return .chooseInGame(startBoxes: startBoxes)
        case 3: // Choose before game
            var startPositions: [Int : StartConfig.Coordinate] = [:]
            try (0..<teamCount).forEach({ (teamNumber: Int) -> Void in
                startPositions[teamNumber] = StartConfig.Coordinate(
                    x: try sections.keyedInteger(for: "StartPosX", from: .team(number: teamNumber)),
                    z: try sections.keyedInteger(for: "StartPosZ", from: .team(number: teamNumber))
                )
            })
            return .chooseBeforeGame(startPositions: startPositions)
        default:
            throw InvalidValueForScriptArgument(section: .game, key: "StartPosType", value: startpostype)
        }
    }

    static func allyTeamsDescribed(by sections: ScriptSections, players: [Int : [Player]], ais: [Int : [AI]]) throws -> [AllyTeam] {
        let teamCount = sections.numberOfSections(withPrefix: "Team")
        if let specifiedTeamCount = try? sections.keyedInteger(for: "NumTeams", from: .game),
            teamCount != specifiedTeamCount {
            print("Warning: value for key \"numplayers\" does not match the number of players.")
        }

        var teamsByAllyTeam: [Int : [Team]] = [:]
        try (0..<teamCount).forEach({
            let colors = try sections.keyedString(for: "RGBColor", from: .team(number: $0))
                .split(separator: " ")
                .map({ UInt32((Double(String($0)) ?? 0.0) * 255) })
            let allyTeam = try sections.keyedInteger(for: "AllyTeam", from: .team(number: $0))

            let newTeam = Team(
                scriptID: $0,
                leader: try sections.keyedInteger(for: "TeamLeader", from: .team(number: $0)),
                players: players[$0] ?? [],
                ais: ais[$0] ?? [],
                color: colors[0] << 16 | colors[1] << 8 | colors[2],
                side: try? sections.keyedString(for: "Side", from: .team(number: $0)),
                handicap: try sections.keyedInteger(for: "Handicap", from: .team(number: $0)),
                advantage: try? sections.keyedFloat(for: "Advantage", from: .team(number: $0)),
                incomeMultiplier: try? sections.keyedFloat(for: "IncomeMultiplier", from: .team(number: $0)),
                luaAI: try? sections.keyedString(for: "LuaAI", from: .team(number: $0))
            )

            if let teams = teamsByAllyTeam[allyTeam] {
                teamsByAllyTeam[allyTeam] = teams + [newTeam]
            } else {
                teamsByAllyTeam[allyTeam] = [newTeam]
            }

        })

        let allyTeamCount = sections.numberOfSections(withPrefix: "AllyTeam")
        if let specifiedAllyTeamCount = try? sections.keyedInteger(for: "NumAllyTeams", from: .game),
            allyTeamCount != specifiedAllyTeamCount {
            print("Warning: value for key \"numallyteams\" does not match the number of ally teams.")
        }
        return (0..<allyTeamCount).map { AllyTeam(scriptID: $0, teams: teamsByAllyTeam[$0] ?? []) }
    }

    static func playersDescribed(by sections: ScriptSections, isFromDemo: Bool) throws -> (spectators: [Player], players: [Int : [Player]]) {

        var spectators: [Player] = []
        var players: [Int : [Player]] = [:]

        let playerCount = sections.numberOfSections(withPrefix: "Player")
        if let specifiedPlayerCount = try? sections.keyedInteger(for: "NumPlayers", from: .game),
            playerCount != specifiedPlayerCount {
            print("Warning: value for key \"numplayers\" does not match the number of players.")
        }
        for playerNumber in 0..<playerCount {
            let player = try Player(scriptID: playerNumber, sections: sections, isFromDemo: isFromDemo)
            let isSpectator = (try? sections.keyedInteger(for: "Spectator", from: .player(number: playerNumber))) ?? 0
            switch isSpectator {
            case 0:
                let team = try sections.keyedInteger(for: "Team", from: .player(number: playerNumber))
                if let teamPlayers = players[team] {
                    players[team] = teamPlayers + [player]
                } else {
                    players[team] = [player]
                }
            case 1:
                spectators.append(player)
            default:
                throw InvalidValueForScriptArgument(section: .player(number: playerNumber), key: "Spectator", value: isSpectator)
            }
        }
        return (spectators, players)
    }
}
