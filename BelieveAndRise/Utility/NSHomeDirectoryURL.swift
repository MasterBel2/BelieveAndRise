//
//  NSHomeDirectoryURL.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 28/7/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// Returns the URL to either the user’s or application’s home directory, depending on the platform.
func NSHomeDirectoryURL() -> URL {
    return URL(string: NSHomeDirectory())!
}

