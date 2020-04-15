//
//  AI.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 15/4/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// Details about an AI that will control the units of a team.
struct AI {
    let name: String
    /// The ID of the player providing the AI
    let hostID: Int
    /// The AI's shortName as given by Unitsync
    let shortName: String
    /// The AI's version as given by unitsync
    let version: String
}
