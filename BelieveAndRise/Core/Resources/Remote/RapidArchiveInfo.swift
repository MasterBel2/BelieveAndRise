//
//  RapidArchive.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 21/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

struct RapidArchiveInfo {
    // Format: shortName:something:version:checksum/something
    let shortName: String
    let tag: String
    let version: String?
    let sdpArchiveName: String
    let mutator: String?
    let name: String
}
