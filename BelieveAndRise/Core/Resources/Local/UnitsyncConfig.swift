//
//  UnitsyncConfig.swift
//  OSXSpringLobby
//
//  Created by Belmakor on 10/12/16.
//  Copyright © 2016 MasterBel2. All rights reserved.
//

import Foundation

struct UnitsyncConfig {

    let unitsyncURL: URL
    var unitsyncPath: String { return unitsyncURL.path }

    init(appURL: URL) {
        let unitsyncLocation = "Contents/MacOS/libunitsync.dylib"
        unitsyncURL = appURL.appendingPathComponent(unitsyncLocation)
    }
}
