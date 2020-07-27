//
//  Replay.swift
//  ReplayParser
//
//  Created by MasterBel2 on 16/5/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// A namespace for errors associated with parsing replay files.
enum ReplayFileError: Error {
    case incorrectHeaderSize
    case unrecognisedVersion
    case missingMagicNumber
}

/// Describes a replay.
struct Replay {

    /// The replay's header metadata.
    let header: Header
    /// The URL to the replay file.
    let fileURL: URL
    /// An object that describes the start conditions for the game.
    let specification: GameSpecification

    init(data: Data, fileURL: URL) throws {
        let dataParser = DataParser(data: data)
        // First check magic number
        let magicNumber = "spring demofile".cString(using: .utf8)!
        guard try dataParser.checkValue(expect: magicNumber) else {
            print("[Replay] Initialisation failed: could not find magic number.")
            throw ReplayFileError.missingMagicNumber
        }

        // Different versions must be parsed differently.
        let version = try dataParser.parseData(ofType: Int32.self)
        let rawHeader: RawReplayHeaderProtocol
        switch version {
        case 5:
            rawHeader = try RawReplayHeader.Version5(dataParser: dataParser, magicNumber: magicNumber)
        case 4:
            rawHeader = try RawReplayHeader.Version4(dataParser: dataParser, magicNumber: magicNumber)
        default:
            print("[Replay] Unrecognised replay version \"\(version)\".")
            throw ReplayFileError.unrecognisedVersion
        }

        let script = try dataParser.parseData(ofType: CChar.self, count: Int(rawHeader.scriptSize))
        // Ensure the script is null-terminated:
        let gameSpecification = try GameSpecificationDecoder().decode(String(cString: script + [0]))

        // Store the useful header data.
        self.header = Header(
            version: Int(version),
            springVersion: String(cString: rawHeader.springVersion),
            gameID: String(cString: rawHeader.gameID),
            gameStartDate: Date(timeIntervalSince1970: TimeInterval(rawHeader.unixTime)),
            duration: Int(rawHeader.gameTime)
        )
        self.specification = gameSpecification
        self.fileURL = fileURL
    }

    /// Contains replay metadata.
    struct Header {
        /// The format of the file the replay was loaded from.
        let version: Int
        /// The Spring version which generated the replay.
        let springVersion: String
        /// A string which uniquely identifies the game.
        let gameID: String
        /// The time at which the game started.
        let gameStartDate: Date
        /// An elapsed time figure (in seconds) measured independently of simulation speed (i.e. 1 game frame corresponds to 1/30 second
        /// regardless of the initial game frames/second the game was played at).
        let duration: Int
    }
}
