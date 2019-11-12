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
                "MOTD" : MOTDCommand.self,
				"SERVERMSG" : SCServerMessageCommand.self,
				"SERVERMSGBOX" : SCServerMessageBoxCommand.self,
				"COMPFLAGS" : SCCompFlagsCommand.self,
				"FAILED" : SCFailedCommand.self,
				"JSON" : SCJSONCommand.self,
				"PONG" : SCPongCommand.self,
				"OK" : SCOKCommand.self,
				
				
				// Interaction commands
				"RING" : SCRingCommand.self,
				"IGNORE" : SCIgnoreCommand.self,
				"UNIGNORE" : SCUnignoreCommand.self,
				"IGNORELIST" : SCIgnoreListCommand.self,
				"IGNORELISTEND" : SCCIgnoreListEndCommand.self,
				
				// Account commands
				"ACCEPTED" : SCLoginAcceptedCommand.self,
				"DENIED" : SCLoginDeniedCommand.self,
				"LOGININFOEND" : SCLoginInfoEndCommand.self,
				"REGISTRATIONDENIED" : SCRegistrationDeniedCommand.self,
				"REGISTRATIONACCEPTED" : SCRegistrationAcceptedCommand.self,
				"AGREEMENT" : SCAgreementCommand.self,
				"AGREEMENTEND" : SCAgreementEndCommand.self,
				"CHANGEEMAILREQUESTACCEPTED" : SCChangeEmailRequestAcceptedCommand.self,
				"CHANGEEMAILREQUESTDENIED" : SCChangeEmailRequestDeniedCommand.self,
				"CHANGEEMAILACCEPTED" : SCChangeEmailAcceptedCommand.self,
				"CHANGEEMAILDENIED" : SCChangeEmailDeniedCommand.self,
				"RESENDVERIFICATIONACCEPTED" : SCResendVerificationAcceptedCommand.self,
				"RESENDVERIFICATIONDENIED" : SCResendVerificationDeniedCommand.self,
				"RESETPASSWORDREQUESTACCEPTED" : SCResetPasswordRequestAcceptedCommand.self,
				"RESETPASSWORDREQUESTDENIED" : SCResetPasswordRequestDeniedCommand.self,
				"RESETPASSWORDACCEPTED" : SCResetPasswordAcceptedCommand.self,
				"RESETPASSWORDDENIED" : SCResetPasswordDeniedCommand.self,

				// User commands
                "ADDUSER" : SCAddUserCommand.self,
				"REMOVEUSER" : SCRemoveUserCommand.self,
				"CLIENTSTATUS" : SCClientStatusCommand.self,
				
				// Client bridging commands
				"BRIDGECLIENTFROM" : SCBridgeClientFromCommand.self,
				"UNBRIDGECLIENTFROM" : SCUnbridgeClientFromCommand.self,
				"JOINEDFROM" : SCJoinedFromCommand.self,
				"LEFTFROM" : SCLeftFromCommand.self,
				"SAIDFROM" : SCSaidFromCommand.self,
				"CLIENTSFROM" : SCClientsFromCommand.self,
				
				// Channel commands
				"JOIN" : SCJoinCommand.self,
				"JOINFAILED" : SCJoinFailedCommand.self,
				"CHANNELTOPIC" : SCChannelTopicCommand.self,
				"CHANNELMESSAGE" : SCChannelMessageCommand.self,
				"SAID" : SCSaidCommand.self,
				"SAIDEX" : SCSaidExCommand.self,
				"CHANNEL" : SCChannelCommand.self,
				"ENDOFCHANNELS" : SCEndOfChannelsCommand.self,

				// Battle commands
                "BATTLEOPENED" : SCBattleOpenedCommand.self,
				"BATTLECLOSESD" : SCBattleClosedCommand.self,
				"JOINEDBATTLE" : SCJoinedBattleCommand.self,
				"LEFTBATTLE" : SCLeftBattleCommand.self,
				"JOINBATTLE" : SCJoinBattleCommand.self,
				"JOINBATTLEFAILED" : SCJoinBattleFailedCommand.self,
				"FORCEQUITBATTLE" : SCForceQuitBattleCommand.self,
				"CLIENTBATTLESTATUS" : SCClientBattleStatusCommand.self,
				"REQUESTBATTLESTATUS" : SCRequestBattleStatusCommand.self,
				"UPDATEBATTLEINFO" : SCUpdateBattleInfoCommand.self,
				"ADDBOT" : SCAddBotCommand.self,
				"REMOVEBOT" : SCRemoveBotCommand.self,
				"ADDSTARTRECT" : SCAddStartRectCommand.self,
				"REMOVESTARTRECT" : SCRemoveStartRectCommand.self,
				"SETSCRIPTTAGS" : SCSetScriptTagsCommand.self,
				"REMOVESCRIPTTAGS" : SCRemoveScriptTagsCommand.self,
				"DISABLEUNITS" : SCDisableUnitsCommand.self,
				"ENABLEUNITS" : SCEnableUnitsCommand.self,
				
				"HOSTPORT" : SCHostPortCommand.self,
				"UDPSOURCEPORT" : SCUDPSourcePortCommand.self,
				
				// Hosting commands
				"OPENBATTLE" : SCOpenBattleCommand.self,
				"OPENBATTLEFAILED" : SCOpenBattleFailedCommand.self,
				"JOINBATTLEREQUEST" : SCJoinBattleRequestCommand.self,
				"CLIENTIPPORT" : SCClientIPPortCommand.self,
				"KICKFROMBATTLE" : SCKickFromBattleCommand.self,
            ]
        default:
            break
        }
    }
}
