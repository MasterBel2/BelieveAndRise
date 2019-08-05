//
//  MOTD.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 13/7/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

struct MOTDCommand: IncomingServerCommand {
    let payload: String
    init?(server: TASServer, payload: String, dataSource: IncomingServerCommandDataSource, delegate: IncomingServerCommandDelegate) {
        self.payload = payload
    }
    func execute() {
        print(payload)
    }
}
