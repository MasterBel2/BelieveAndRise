//
//  MOTD.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 13/7/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/// See https://springrts.com/dl/LobbyProtocol/ProtocolDescription.html#MOTD:server
struct MOTDCommand: SCCommand {
    let payload: String

    init(payload: String) {
        self.payload = payload
    }

    init?(description: String) {
        payload = description
    }

    var description: String {
        return "MOTD \(payload)"
    }

    func execute(on connection: Connection) {
        print(payload)
    }
}
