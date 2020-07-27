//
//  AllyTeam.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 15/4/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// Information about the teams that make up an AllyTeam.
struct AllyTeam {
    /// An integer that is garuanteed to uniquely identify this allyteam in the start script.
    let scriptID: Int
    /// The teams that make up this AllyTeam.
    ///
    /// Team number is determined by position in the array. (I.e. Team 0 is position 0, etc.)
    let teams: [Team]

    init(scriptID: Int, teams: [Team]) {
        self.teams = teams
        self.scriptID = scriptID
    }
}
