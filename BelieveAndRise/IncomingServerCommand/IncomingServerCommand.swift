//
//  IncomingServerCommand.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 30/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

protocol IncomingServerCommand {
    init?(server: TASServer, payload: String, dataSource: IncomingServerCommandDataSource, delegate: IncomingServerCommandDelegate)
    /// Executes the command.
    func execute()
}

struct DummyCommand: IncomingServerCommand {
    init?(server: TASServer, payload: String, dataSource: IncomingServerCommandDataSource, delegate: IncomingServerCommandDelegate) {}
    func execute() {}
}
