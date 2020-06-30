//
//  debugOnlyPrint.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 30/6/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// Executes a print, only if it is a debug build.
func debugOnlyPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    print(items, separator: separator, terminator: terminator)
    #endif
}
