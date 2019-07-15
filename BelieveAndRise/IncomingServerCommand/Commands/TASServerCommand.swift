//
//  TASServerCommand.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 15/7/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

struct TASServerCommand: IncomingServerCommand {
    weak var delegate: IncomingServerCommandDelegate?
    let server: TASServer
    init?(server: TASServer, arguments: [String], dataSource: IncomingServerCommandDataSource, delegate: IncomingServerCommandDelegate) {
        self.delegate = delegate
        self.server = server
    }

    func execute() {
        delegate?.connectedToServer(server)
    }
}
