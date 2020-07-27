//
//  StartConfig.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 15/4/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// Describes how the players should be distributed for a game.
enum StartConfig {
    /// Indicates that player locations have been chosen before the game.
    case chooseBeforeGame(startPositions: [Int : Coordinate])
    /// Indicates that the players should be distributed according to the map's set locations, in the order the players are given to the
    /// map.
    case fixed
    /// Indicates that the players should be allowed to select their start location in-game, within any specified start boxes.
    case chooseInGame(startBoxes: [Int : StartBox])
    /// Indicates that the players should be randomly distributed according to the map's set locations.
    case random

    struct Coordinate {
        let x: Int
        let z: Int
    }
}
