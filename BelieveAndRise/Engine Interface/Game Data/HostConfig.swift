//
//  HostConfig.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 15/4/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// A set of information about the host required by the engine to launch a game.
struct HostConfig {
    /// The unique ID associated with the host's account.
    let userID: Int?
    /// The host's username.
    let username: String
    /// Information about the host program.
    let type: HostType
    ///
    let address: ServerAddress
    /// The lobby rank of the host account.
    let rank: Int?
    /// The country code describing the location from which the host connects.
    let countryCode: CountryCode?

    /// A set of cases describing the game is being hosted.
    enum HostType {
        /// Indicates that the host is an autonomous program.
        case autohost((programName: String, port: Int))
        /// Indicates that the host is a user with a lobby client.
        case user(lobbyName: String)
    }
}
