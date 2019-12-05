//
//  LaunchScriptWriter.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 4/12/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

///
protocol LaunchScriptComponent: CustomStringConvertible {}

/// A structure that encapsulates information about the game to be hosted by the spring instance to be written in a launchscript.
final class LaunchScriptWriter {
    let fileManager = FileManager.default

    let dir = "\(NSHomeDirectory())/.spring/"
    let filePath = "\(NSHomeDirectory())/.spring/script.txt"
    let fileName = "script.txt"

    /// Writes a file containing the specified string.
    private func setFile(at location: String, with contents: String) {
        guard let contentsData = contents.data(using: .utf8) else {
            fatalError("Fatal Error: cannot convert file contents from String to Data")
        }
        fileManager.createFile(atPath: filePath, contents: contentsData, attributes: nil)
    }

    /// Creates a launch script that configures the engine to play back the specified replay file.
    func prepareForLaunchOfReplay(_ replay: Replay) {
        let fileContents = Section(
            title: "GAME",
            components: [
                Argument(key: "DemoFile", value: replay.fileName)
            ]
        ).description
        // FIXME: - This is an incomplete implementation.
        #warning("TODO")
        setFile(at: filePath, with: fileContents.description)
    }


    /// Writes a launch script describing the properties of a locally hosted game.
    func prepareForLaunchOfSinglePlayerGame(_ game: HostedGame) {
        let playerSections: [LaunchScriptComponent] = {
            var playerSections: [Section] = []
            for (index, player) in game.players.enumerated() {
                playerSections.append(Section(
                    title: "PLAYER\(index)",
                    components: [
                        Argument(key: "name", value: player.username),
                        Argument(key: "countrycode", value: String(player.countryCode.name)),
                        Argument(key: "rank", value: String(player.rank)),
                        Argument(key: "skill", value: player.skill),
                        Argument(key: "spectator", value: String(player.isSpectator ? 1 : 0)),
                        Argument(key: "team", value: String(player.team)),
                        Argument(key: "isfromdemo", value: String(player.isFromDemo ? 1 : 0)),
                    ]
                ))
            }
            return playerSections
        }()

        let aiSections: [LaunchScriptComponent] = {
            var aiSections: [Section] = []
            for (index, ai) in game.ais.enumerated() {
                aiSections.append(Section(
                    title: "AI\(index)",
                    components: [
                        Argument(key: "name", value: ai.name),
                        Argument(key: "host", value: String(ai.host)),
                        Argument(key: "isfromdemo", value: String(ai.isFromDemo ? 1 : 0)),
                        Argument(key: "team", value: String(ai.team)),
                        Argument(key: "shortname", value: ai.shortName),
                        Argument(key: "version", value: ai.version),
                    ]
                ))
            }
            return aiSections
        }()

        let teamSections: [LaunchScriptComponent] = {
            var teamSections: [Section] = []
            for (index, team) in game.teams.enumerated() {
                teamSections.append(Section(
                    title: "TEAM\(index)",
                    components: [
                        Argument(key: "teamleader", value: String(team.leader)),
                        Argument(key: "allyteam", value: String(team.allyTeamNumber)),
                        Argument(key: "rgbcolor", value: "\(team.rgbColor.r) \(team.rgbColor.g) \(team.rgbColor.b))"),
                        Argument(key: "handicap", value: team.handicap),
                        Argument(key: "advantage", value: String(team.advantage)),
                        Argument(key: "incomemultiplier", value: String(team.incomeMultiplier)),
                        Argument(key: "startposx", value: String(team.startPosX)),
                        Argument(key: "startposz", value: String(team.startPosZ)),
                        Argument(key: "luaai", value: String(team.luaAI)),

                    ]
                ))
            }
            return aiSections
        }()

        let modoptionSection = Section(
            title: "ModOptions",
            components: game.modOptions.map({ Argument(key: $0.name, value: $0.value) })
        )

        let gameArguments: [LaunchScriptComponent] = [
            Argument(key: "myplayername", value: game.myPlayerName),
            Argument(key: "gametype", value: game.gameType),
            Argument(key: "startpostype", value: String(game.startPosType.rawValue)),
            Argument(key: "gamestartdelay", value: String(game.gameStartDelay)),

            Argument(key: "numallyteams", value: String(game.allyTeams.count)),
            Argument(key: "numrestrictions", value: String(game.restrictions.count)),
            Argument(key: "numteams", value: String(game.teams.count)),
            Argument(key: "numplayers", value: String(game.players.count)),
            Argument(key: "numusers", value: String(game.players.count + game.ais.count)),

            Argument(key: "mapname", value: game.mapName),
            Argument(key: "maphash", value: String(game.mapHash)),
            Argument(key: "mapname", value: game.gameName),
            Argument(key: "modhash", value: String(game.modHash)),
            Argument(key: "startpostype", value: String()),

            Argument(key: "ishost", value: "1"),
            Argument(key: "hosttype", value: game.hostType),
            Argument(key: "hostip", value: game.hostIp),
            Argument(key: "hostport", value: String(game.hostPort)),

            Argument(key: "autohostaccountid", value: ""),
            Argument(key: "autohostcountrycode", value: ""),
            Argument(key: "autohostname", value: ""),
            Argument(key: "autohostrank", value: ""),

            Argument(key: "demofile", value: ""),

            Argument(key: "dorecorddemo", value: String(game.doRecordDemo ? 1 : 0)),
        ]

        let fileContents = Section(
            title: "GAME",
            components: playerSections + aiSections + teamSections + [modoptionSection] + gameArguments
        )

        setFile(at: filePath, with: fileContents.description)
    }

    /// Creates a launchscript which configures the engine to connect to the specified host.
    func prepareForLaunchOfSpringAsClient(ip: String, port: Int, username: String, scriptPassword: String) {
        let fileContents = Section(
            title: "GAME",
            components: [
                Argument(key: "HostIP", value: ip),
                Argument(key: "HostPort", value: String(port)),
                Argument(key: "MyPlayerName", value: username),
                Argument(key: "MyPasswd", value: scriptPassword),
                Argument(key: "IsHost", value: String(0)),
            ]
        )
        setFile(at: filePath, with: fileContents.description)
    }

    /// Represents a key-value pair that specifies a configuration property for an engine launchscript
    private struct Argument: LaunchScriptComponent {
        let key: String
        let value: String

        var description: String {
            return "\(key)=\(value);"
        }
    }

    /// Represents a section in a launchscript containing key-value pairs.
    private struct Section: LaunchScriptComponent {
        let title: String
        let components: [LaunchScriptComponent]

        var description: String {
            return """
            [\(title)]\n
            {\n
            \(components.map({ $0.description }).joined(separator: "\n"))\n
            }
            """
        }
    }
}
