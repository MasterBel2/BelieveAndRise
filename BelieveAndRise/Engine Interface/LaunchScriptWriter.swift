//
//  LaunchScriptWriter.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 4/12/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

///
protocol LaunchScriptComponent: CustomStringConvertible {}

/// A structure that encapsulates information about the game to be hosted by the spring instance to be written in a launchscript.
final class LaunchScriptWriter {

    // MARK: - Dependencies
    let fileManager = FileManager.default

    // MARK: - Constants

    static let dir = "\(NSHomeDirectory())/.spring/"
    static var filePath: String {
        return dir + fileName
    }
    static let fileName = "script.txt"

    /// Writes a file containing the specified string.
    private func setFile(at location: String, with contents: String) {
        guard let contentsData = contents.data(using: .utf8) else {
            fatalError("Fatal Error: cannot convert file contents from String to Data")
        }
        fileManager.createFile(atPath: location, contents: contentsData, attributes: nil)
    }

    // MARK: - API

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
        setFile(at: LaunchScriptWriter.filePath, with: fileContents.description)
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
        setFile(at: LaunchScriptWriter.filePath, with: fileContents.description)
    }

    /// Writes a launch script describing the properties of a locally hosted game.
    func prepareForLaunchOfSpringAsHost(_ game: HostedGame) {
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
                var components = [
                    Argument(key: "teamleader", value: String(team.leader)),
                    Argument(key: "allyteam", value: String(team.allyTeamNumber)),
                    Argument(key: "rgbcolor", value: "\(team.rgbColor.red) \(team.rgbColor.green) \(team.rgbColor.blue))"),
                    Argument(key: "handicap", value: team.handicap),
                    Argument(key: "advantage", value: String(team.advantage)),
                    Argument(key: "incomemultiplier", value: String(team.incomeMultiplier)),
                    Argument(key: "luaai", value: String(team.luaAI))
                ]

                if let startPositionX = team.startPosX {
                    components.append(Argument(key: "startposx", value: String(startPositionX)))
                }
                if let startPositionZ = team.startPosZ {
                    components.append(Argument(key: "startposz", value: String(startPositionZ)))
                }

                teamSections.append(Section(title: "TEAM\(index)", components: components))
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
            Argument(key: "startpostype", value: String(game.startPositionType.rawValue)),
            Argument(key: "gamestartdelay", value: String(game.gameStartDelay)),

            Argument(key: "numallyteams", value: String(game.allyTeams.count)),
            Argument(key: "numrestrictions", value: String(game.restrictions.count)),
            Argument(key: "numteams", value: String(game.teams.count)),
            Argument(key: "numplayers", value: String(game.players.count)),
            Argument(key: "numusers", value: String(game.players.count + game.ais.count)),

            Argument(key: "mapname", value: game.mapName),
            Argument(key: "maphash", value: String(game.mapHash)),
            // SpringLobby does not use this argument
//            Argument(key: "gamename", value: game.gameName),
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

        setFile(at: LaunchScriptWriter.filePath, with: fileContents.description)
    }

    // MARK: - Launch Script Components

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

    // MARK: - Launch Script data

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
    ///
    /// Documentation has been copied from the [SpringRTS wiki](https://springrts.com/wiki/Script.txt).
    struct HostedGame {
        // [GAME] {
        let myPlayerName: String
        let mapName: String // Name of the file
        let mapHash: Int32
        // SpringLobby doesn't use this value
//        let gameName: String
        let modHash: Int32
        let gameType: String // either primary mod NAME, rapid tag name or archive name
        let gameStartDelay: Int // optional, in seconds, (unsigned int), default: 4
        let startPositionType: StartPositionType // 0 fixed, 1 random, 2 choose in game, 3 choose before game (see StartPosX)

        let doRecordDemo: Bool // when finally input, 0 for false and 1 for true

        let hostType: String
        let hostIp: String //
        let hostPort: Int //
        let isHost: Bool = true // 1 for true, 0 for false


        struct Autohost {
            let id: Int
            let countryCode: CountryCode
            let name: String
            let rank: String
        }

        let autohost: Autohost?

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
        /// The number of the player the AI is associated with
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
        let countryCode: CountryCode // Country code of the player.
        let isFromDemo: Bool //

        let rank: Int
        let skill: String

        let team: Int // The team number controlled by the player
        let isSpectator: Bool // 1 for true, 0 for false
        // }
    }

    /// A structure that encapsulates information about a team to be written in a launchscript
    struct Team {
        // [TEAM0] {
        let leader: Int // Player number of the leader
        let allyTeamNumber: Int
        let rgbColor: (red: Float, green: Float, blue: Float) // r g b in range 0 to 1
        let side: String // Arm/Core; other sides possible with mods other than BA
        let handicap = "0" // Deprecated, see advantage; but is -100 to 100 - % resource income bonus

        let advantage: Int // Advantage factor (meta value). Currently only affects incomeMultiplier (below). Valid: [-1.0, FLOAT_MAX]
        let incomeMultiplier: Int // multiplication factor for collected resources. valid [0.0, FLOAT_MAX]
        let startPosX: Int? // Use these in combination with StartPosType = 3
        let startPosZ: Int? // Range is in map coordinates as returned by UnitSync
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
        let allies: [String] = [] // means that this team is allied with the other, not necesarily the reverse (just put each allied allyteam in the array and you can cycle through them, ok?)
        let startRectTop: String?   // Use these in combination with StartPosType=2
        let startRectLeft: String?   //   (ie. select in map)
        let startRectBottom: String? // range is 0-1: 0 is left or top edge,
        let startRectRight: String?  //   1 is right or bottom edge
    }

    /// A structure that encapsulates mod option information to be written in a launchscript
    struct ModOption {
        let name: String
        var value: String
    }
}
