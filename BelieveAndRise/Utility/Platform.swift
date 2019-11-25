//
//  Platform.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 21/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

enum Platform: String {
    case Linux = "engine_linux"
    case Linux64 = "engine_linux64"
    case Windows = "engine_windows"
    case Windows64 = "engine_windows64"
    case macOS = "engine_macosx"
}

var platform: Platform {
    #if os(Linux)
    if Int.bitWidth == Int64.bitWidth {
        return .Linux64
    } else {
        return .Linux
    }
    #elseif os(macOS)
    return .macOS
    #elseif os(Windows)
    if Int.bitWidth == Int64.bitWidth {
        return .Windows64
    } else {
        return .Windows
    }
    #endif
}
