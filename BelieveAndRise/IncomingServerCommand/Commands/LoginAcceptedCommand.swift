//
//  LoginAcceptedCommand.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 15/7/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

struct LoginAcceptedCommand: IncomingServerCommand {
    weak var delegate: IncomingServerCommandDelegate?
    init?(server: TASServer, payload: String, dataSource: IncomingServerCommandDataSource, delegate: IncomingServerCommandDelegate) {
        self.delegate = delegate
    }
    func execute() {
        delegate?.completeLogin()
    }
}
