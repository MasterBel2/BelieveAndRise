//
//  ServerCommandParser.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 30/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

final class CommandHandler: TASServerDelegate {

    // MARK: - Dependencies

    weak var connection: Connection?

    // MARK: - Interaction

    var userAuthenticationController: UserAuthenticationController?

    private weak var battelistViewController: ListViewController?

    // MARK: - Something

	private var incomingCommands: [String : SCCommand.Type] = [:]
	
	// MARK: - Lifecycle
	
	init() {
		setProtocol(.unknown)
	}

    // MARK: - TASServerDelegate

    func server(_ server: TASServer, didReceive serverCommand: String) {
        // If the connection no longer exists, there's no benefit to receiving further commands
        // from the server, so we'll disconnect.
        guard let connection = connection else {
            server.disconnect()
            return
        }

        debugOnlyPrint(serverCommand)

        let components = serverCommand.components(separatedBy: " ")
        let description = components.dropFirst().joined(separator: " ")
        guard let _command = components.first?.uppercased(),
            let recognisedCommand = incomingCommands[_command],
            let command = recognisedCommand.init(description: description) else {
                return
        }
        command.execute(on: connection)
    }

    // MARK: - TASServerDelegate

    ///
    enum ServerProtocol {
		case unknown
        case tasServer(version: String)
        case zeroKServer
    }

    func setProtocol(_ serverProtocol: ServerProtocol) {
        switch serverProtocol {
		case .unknown:
			incomingCommands = [
				"TASSERVER" : TASServerCommand.self
			]
        case .tasServer(_):
            incomingCommands = [
                "TASSERVER" : TASServerCommand.self,
				"REDIRECT" : SCRedirectCommand.self,
                "ACCEPTED" : SCLoginAcceptedCommand.self,
                "MOTD" : MOTDCommand.self,

                "ADDUSER" : SCAddUserCommand.self,

                "BATTLEOPENED" : BattleOpenedCommand.self,
            ]
        default:
            break
        }
    }
}
