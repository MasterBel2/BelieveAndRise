//
//  String+utf8CStringArray.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 30/7/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

extension String {
    /// A contiguously stored null-terminated utf8 C string.
    var utf8CStringArray: [CChar] {
        return Array(utf8CString)
    }
}
