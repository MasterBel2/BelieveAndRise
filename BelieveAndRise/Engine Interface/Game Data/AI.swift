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
    /// An integer for uniquely identifying the AI within the startscript.
    let scriptID: Int
    /// The nickname for the AI instance.
    let name: String
    /// The ID of the player providing the AI
    let hostID: Int
    /// The AI's shortName as given by Unitsync
    let shortName: String
    /// The AI's version as given by unitsync
    let version: String

    /// Whether or not the AI come from a demo.
    let isFromDemo: Bool
}
