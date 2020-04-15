//
//  Player.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 15/4/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// Describes a player that will control units of a team.
struct Player {
    /// The unique lobby ID of the player.
    let userID: Int
    /// The username of the player.
    let username: String
    /// The password the user will send on a connect attempt.
    let scriptPassword: String

    /// The trueskill value of the player, if they have one.
    let skill: String?
    /// The lobby rank of the player, if applicable.
    let rank: Int?
    /// The country code associated with the player's location.
    let countryCode: CountryCode
}
