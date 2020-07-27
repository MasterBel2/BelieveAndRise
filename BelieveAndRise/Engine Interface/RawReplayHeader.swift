//
//  RawReplayHeader.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 28/7/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// Describes general properties of a replay header.
protocol RawReplayHeaderProtocol {
    var magicNumber: [CChar] { get }
    var version: Int32 { get }
    var headerSize: Int32 { get }
    var springVersion: [CChar] { get }
    var gameID: [UInt8] { get }
    var unixTime: Int64 { get }
    var scriptSize: Int32 { get }
    var demoStreamSize: Int32 { get }
    var gameTime: Int32 { get }
    var wallclockTime: Int32 { get }
    var numPlayers: Int32 { get }
    var playerStatSize: Int32 { get }
    var playerStatElementSize: Int32 { get }
    var teamStatisticsCount: Int32 { get }
    var teamStatSize: Int32 { get }
    var teamStatElementSize: Int32 { get }
    var teamStatPeriod: Int32 { get }
    var winningAllyTeamSize: Int32 { get }
}

enum RawReplayHeader {
    /// Describes a replay file format with a spring version of 256 characters.
    struct Version5: RawReplayHeaderProtocol {
        let magicNumber: [CChar]
        /// The file format version of the replay.
        let version: Int32 = 5
        /// The size of the replay header, in bytes.
        ///
        /// Accorrding to SpringLobby, this begins at byte 20.
        let headerSize: Int32
        /// An array of characters describing the spring version of the replay, with up to 256 8-bit characters (16 if version 5 or lower).
        let springVersion: [CChar]
        /// A unique identifier for the game.
        let gameID: [UInt8]
        /// The unix time when the game started.
        let unixTime: Int64

        /// The size (in bytes) of the startScript.
        let scriptSize: Int32
        /// The size (in bytes) of the demo stream.
        let demoStreamSize: Int32
        /// Total number of seconds game time.
        let gameTime: Int32
        /// Total number of seconds wallclock time.
        let wallclockTime: Int32

        /// The number of players (including spectators, and spectators joined after game start).
        let numPlayers: Int32
        /// The size of the entire player statistics chunk
        let playerStatSize: Int32
        /// The size of the C++ struct containing the statistics about a single player.
        let playerStatElementSize: Int32
        /// The number of teams (not allyteams!) for which stats are saved.
        let teamStatisticsCount: Int32
        /// The size of the entire team statistics chunk.
        let teamStatSize: Int32
        /// The size of the C++ struct containing the statistics about a single team.
        let teamStatElementSize: Int32
        /// The interval (in seconds) between team stats. (???)
        let teamStatPeriod: Int32
        /// The size of the vector of the winning allyteams
        let winningAllyTeamSize: Int32

        init(dataParser: DataParser, magicNumber: [CChar]) throws {
            self.magicNumber = magicNumber
            self.headerSize = try dataParser.parseData(ofType: Int32.self)
            self.springVersion = try dataParser.parseData(ofType: CChar.self, count: 256)
            self.gameID = try dataParser.parseData(ofType: UInt8.self, count: 16)
            self.unixTime = try dataParser.parseData(ofType: Int64.self)
            self.scriptSize = try dataParser.parseData(ofType: Int32.self)
            self.demoStreamSize = try dataParser.parseData(ofType: Int32.self)
            self.gameTime = try dataParser.parseData(ofType: Int32.self)
            self.wallclockTime = try dataParser.parseData(ofType: Int32.self)
            self.numPlayers = try dataParser.parseData(ofType: Int32.self)
            self.playerStatSize = try dataParser.parseData(ofType: Int32.self)
            self.playerStatElementSize = try dataParser.parseData(ofType: Int32.self)
            self.teamStatisticsCount = try dataParser.parseData(ofType: Int32.self)
            self.teamStatSize = try dataParser.parseData(ofType: Int32.self)
            self.teamStatElementSize = try dataParser.parseData(ofType: Int32.self)
            self.teamStatPeriod = try dataParser.parseData(ofType: Int32.self)
            self.winningAllyTeamSize = try dataParser.parseData(ofType: Int32.self)

            guard dataParser.currentIndex == Int(headerSize) else {
                print("[Replay (Header Version 6)] Initialisation failed: expected header size \(headerSize), read \(dataParser.currentIndex) bytes instead.")
                throw ReplayFileError.incorrectHeaderSize
            }
        }
    }

    /// Describes a replay file format with a spring version of only 16 characters.
    struct Version4: RawReplayHeaderProtocol {
        let magicNumber: [CChar]
        /// The file format version of the replay.
        let version: Int32 = 4
        /// The size of the replay header, in bytes.
        ///
        /// Accorrding to SpringLobby, this begins at byte 20.
        let headerSize: Int32
        /// An array of characters describing the spring version of the replay, with up to 16 characters.
        let springVersion: [CChar]
        /// A unique identifier for the game.
        let gameID: [UInt8]
        /// The unix time when the game started.
        let unixTime: Int64

        /// The size (in bytes) of the startScript.
        let scriptSize: Int32
        /// The size (in bytes) of the demo stream.
        let demoStreamSize: Int32
        /// Total number of seconds game time.
        let gameTime: Int32
        /// Total number of seconds wallclock time.
        let wallclockTime: Int32

        /// The number of players (including spectators, and spectators joined after game start).
        let numPlayers: Int32
        /// The size of the entire player statistics chunk
        let playerStatSize: Int32
        /// The size of the C++ struct containing the statistics about a single player.
        let playerStatElementSize: Int32
        /// The number of teams (not allyteams!) for which stats are saved.
        let teamStatisticsCount: Int32
        /// The size of the entire team statistics chunk.
        let teamStatSize: Int32
        /// The size of the C++ struct containing the statistics about a single team.
        let teamStatElementSize: Int32
        /// The interval (in seconds) between team stats. (???)
        let teamStatPeriod: Int32
        /// The size of the vector of the winning allyteams
        let winningAllyTeamSize: Int32

        init(dataParser: DataParser, magicNumber: [CChar]) throws {
            self.magicNumber = magicNumber
            self.headerSize = try dataParser.parseData(ofType: Int32.self)
            self.springVersion = try dataParser.parseData(ofType: CChar.self, count: 16)
            self.gameID = try dataParser.parseData(ofType: UInt8.self, count: 16)
            self.unixTime = try dataParser.parseData(ofType: Int64.self)
            self.scriptSize = try dataParser.parseData(ofType: Int32.self)
            self.demoStreamSize = try dataParser.parseData(ofType: Int32.self)
            self.gameTime = try dataParser.parseData(ofType: Int32.self)
            self.wallclockTime = try dataParser.parseData(ofType: Int32.self)
            self.numPlayers = try dataParser.parseData(ofType: Int32.self)
            self.playerStatSize = try dataParser.parseData(ofType: Int32.self)
            self.playerStatElementSize = try dataParser.parseData(ofType: Int32.self)
            self.teamStatisticsCount = try dataParser.parseData(ofType: Int32.self)
            self.teamStatSize = try dataParser.parseData(ofType: Int32.self)
            self.teamStatElementSize = try dataParser.parseData(ofType: Int32.self)
            self.teamStatPeriod = try dataParser.parseData(ofType: Int32.self)
            self.winningAllyTeamSize = try dataParser.parseData(ofType: Int32.self)

            guard dataParser.currentIndex == Int(headerSize) else {
                print("[Replay (Header Version 5)] Initialisation failed: expected header size \(headerSize), read \(dataParser.currentIndex) bits instead.")
                throw ReplayFileError.incorrectHeaderSize
            }
        }
    }
}
