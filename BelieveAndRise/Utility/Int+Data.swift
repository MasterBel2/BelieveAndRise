//
//  Int+Data.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 21/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

extension Int {
    init?(data: Data) {
        var value: Self = 0
        _ = withUnsafeMutableBytes(of: &value, { data.copyBytes(to: $0)} )
        self = value
    }
}
