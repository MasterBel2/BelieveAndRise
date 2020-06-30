//
//  ServerAddress.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 19/6/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// Specifies the location of a server.
struct ServerAddress {
    /// The domain/IP of a server
    let location: String
    /// The port on which the connection should be made
    let port: Int
}
