//
//  Resource.swift
//  BelieveAndRise
//
//  Created by MasterBe2l on 21/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

enum Resource {
    case engine(name: String, platform: Platform)
    case map(name: String)
    case game(name: String)
    var category: String {
        switch self {
        case .map:
            return "map"
        case .game:
            return "game"
        case .engine(let (_, version)):
            return version.rawValue
        }
    }
    var directory: String {
        switch self {
        case .map:
            return "maps"
        case .game:
            return "games"
        case .engine:
            return "enignes"
        }
    }
    var name: String {
        switch self {
        case .map(let name):
            return name
        case .game(let name):
            return name
        case .engine(let (name, _)):
            return name
        }
    }
}
