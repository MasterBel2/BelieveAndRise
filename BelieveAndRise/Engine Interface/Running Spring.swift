//
//  Running Spring.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 15/4/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

///
///
func launchScriptHostedGame(from gameData: GameData, wantsReplayRecorded: Bool) -> LaunchScriptWriter.HostedGame {
    let launchScriptWriter = LaunchScriptWriter()

    let autohost: LaunchScriptWriter.HostedGame.Autohost?
    let hostType: String

    var playerIndex = 0

    var scriptTeams: [LaunchScriptWriter.Team] = []
    var scriptPlayers: [LaunchScriptWriter.Player] = []
    var scriptAIs: [LaunchScriptWriter.AI] = []
    var scriptAllyTeams: [LaunchScriptWriter.AllyTeam] = []

    let startPositionType: LaunchScriptWriter.StartPositionType
    var startPositions: [Int : (x: Int, z: Int)] = [:]
    var startBoxes: [Int : StartBox] = [:]
    switch gameData.startConfig {
    case .chooseBeforeGame(let _startPositions):
        startPositions = _startPositions
        startPositionType = .chooseBeforeGame
    case .chooseInGame(let _startBoxes):
        startBoxes = _startBoxes
        startPositionType = .chooseInGame
    case .fixed:
        startPositionType = .fixed
    case .random:
        startPositionType = .random
    }

    for (allyTeamIndex, allyTeam) in gameData.allyTeams.enumerated() {
        if let startRect = startBoxes[allyTeamIndex] {
            let bottom = Float(startRect.y)
            let top = Float(startRect.y + startRect.height)
            let left = Float(startRect.x)
            let right = Float(startRect.x + startRect.width)
            scriptAllyTeams.append(
                LaunchScriptWriter.AllyTeam(
                    startRectTop: String(top),
                    startRectLeft: String(left),
                    startRectBottom: String(bottom),
                    startRectRight: String(right)
                )
            )
        } else {
            scriptAllyTeams.append(
                LaunchScriptWriter.AllyTeam(
                    startRectTop: nil,
                    startRectLeft: nil,
                    startRectBottom: nil,
                    startRectRight: nil
                )
            )
        }
        for (teamIndex, team) in allyTeam.teams.enumerated() {
            scriptTeams.append(
                LaunchScriptWriter.Team(
                    leader: playerIndex,
                    allyTeamNumber: allyTeamIndex,
                    rgbColor: team.color.rgbValues,
                    side: team.side,
                    advantage: team.handicap,
                    incomeMultiplier: 0, // What does this do??
                    startPosX: startPositions[teamIndex]?.x,
                    startPosZ: startPositions[teamIndex]?.z
                )
            )
            for player in team.players {
                let scriptPlayer = LaunchScriptWriter.Player(
                    username: player.username,
                    password: player.scriptPassword,
                    countryCode: player.countryCode,
                    isFromDemo: false,
                    rank: player.rank ?? 0,
                    skill: player.skill ?? String(player.rank ?? 0),
                    team: teamIndex,
                    isSpectator: false
                )
                scriptPlayers.append(scriptPlayer)
                playerIndex += 1
            }
            for ai in team.ais {
                scriptAIs.append(
                    LaunchScriptWriter.AI(
                        name: ai.name,
                        host: ai.hostID,
                        isFromDemo: false,
                        team: teamIndex,
                        shortName: ai.shortName,
                        version: ai.version
                    )
                )
            }
        }
    }

    for spectator in gameData.spectators {
        #warning("SpringLobby sets \"team\" to 0. What is it supposed to be?")
        let scriptPlayer = LaunchScriptWriter.Player(
            username: spectator.username,
            password: spectator.scriptPassword,
            countryCode: spectator.countryCode,
            isFromDemo: false,
            rank: spectator.rank ?? 0,
            skill: spectator.skill ?? String(spectator.rank ?? 0),
            team: -1,
            isSpectator: true
        )
        scriptPlayers.append(scriptPlayer)
        playerIndex += 1
    }

    switch gameData.hostConfig.type {
    case .user(let lobbyName):
        hostType = lobbyName
        autohost = nil
    case .autohost(let programName):
        hostType = programName
        autohost = LaunchScriptWriter.HostedGame.Autohost(
            id: gameData.hostConfig.userID,
            countryCode: gameData.hostConfig.countryCode,
            name: gameData.hostConfig.username,
            rank: String(gameData.hostConfig.rank)
        )
    }

    #warning("TODO: Modoptions, Restrictions")

    return LaunchScriptWriter.HostedGame(
        myPlayerName: gameData.hostConfig.username,
        mapName: gameData.mapName,
        mapHash: gameData.mapHash,
        // SpringLobby doesn't use this value
//        gameName: ,
        modHash: gameData.modHash,
        gameType: gameData.gameType,
        gameStartDelay: 0,
        startPositionType: startPositionType,
        doRecordDemo: wantsReplayRecorded,
        hostType: hostType,
        hostIp: gameData.hostConfig.address.location,
        hostPort: gameData.hostConfig.address.port,
        autohost: nil,
        demoFile: gameData.demoFile?.path ?? "",
        players: scriptPlayers,
        ais: scriptAIs,
        teams: scriptTeams,
        allyTeams: scriptAllyTeams,
        restrictions: [],
        modOptions: []
    )
}
