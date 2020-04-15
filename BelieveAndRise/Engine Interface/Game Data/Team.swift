//
//  Team.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 15/4/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// Describes a team of players and/or AIs that will control a single set of units/resources.
struct Team {
    #warning("It is unclear what effect this has, if any.")
    /// The "leader" of the team.
    let leader: Int
    /// The human players on the team.
    let players: [Player]
    /// The AI players on the team.
    ///
    /// Note that due to the design of AIs, AIs will likely only ever be on their own team.
    let ais: [AI]

    /// The color assigned to the team.
    let color: UInt32
    /// The faction assigned to the team.
    let side: String

    /// ??? Not sure what a handicap is.
    let handicap: Int
}
