//
//  MOTD.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 13/7/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

struct MOTDCommand: IncomingServerCommand {
    let arguments: [String]
    init?(server: TASServer, arguments: [String], dataSource: IncomingServerCommandDataSource, delegate: IncomingServerCommandDelegate) {
        self.arguments = arguments
    }
    func execute() {
        print(arguments.joined(separator: " "))
    }
}
