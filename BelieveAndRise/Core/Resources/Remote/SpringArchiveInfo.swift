//
//  SpringArchiveInfo.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 21/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

struct SpringArchiveInfo: Decodable {
    let category: String
    let description: String?
    let filename: String
    let mirrors: [URL]
    let md5: String
    let name: String
    let sdp: String
    let size: Int
    let springname: String
    let tags: [String]
    let timestamp: String
    let version: String
}
