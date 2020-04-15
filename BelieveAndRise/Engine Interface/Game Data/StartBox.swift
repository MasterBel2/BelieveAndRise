//
//  StartBox.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 15/4/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// Describes an area in which members of an allyteam may choose their start positions.
///
/// Values are scaled from 0-200 on the X and Y coordinates, So on a 1000x500 map, a starbox x = 100 would relate to map's x = 500,
/// and a startbox y = 100 would relate to map's y = 250.
struct StartBox {
    /// The upper left X coordinate.
    let x: Int
    /// The upper left Y coordinate.
    let y: Int
    /// The width of the startbox.
    let width: Int
    /// The height of the startbox.
    let height: Int
}
