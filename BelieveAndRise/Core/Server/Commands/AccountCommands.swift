//
//  LoginAcceptedCommand.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 15/7/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/**
 Sent as a response to the LOGIN command, if it succeeded. Next, the server will send much info
 about clients and battles:

 - multiple MOTD, each giving one line of the current welcome message
 - multiple ADDUSER, listing all users currently logged in
 - multiple BATTLEOPENED, UPDATEBATTLEINFO, detailing the state of all currently open battles
 - multiple JOINEDBATTLE, indiciating the clients present in each battle
 - multiple CLIENTSTATUS, detailing the statuses of all currently logged in users
 */
struct SCLoginAcceptedCommand: SCCommand {

    // MARK: - Properties

    let username: String

    // MARK: - Manual Construction

    init(username: String) {
        self.username = username
    }

    // MARK:  SCCommand

    init?(description: String) {
        guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 0) else {
            return nil
        }
        username = words[0]
    }

    var description: String {
        return "ACCEPTED \(username)"
    }

    func execute(on connection: Connection) {
        connection.windowController._window?.dismissPrompts()
    }
}

/**
Sent as a response to a failed LOGIN command.
*/
struct SCLoginDeniedCommand: SCCommand {
	
	let reason: String
	
	// MARK: - Manual Construction
	
	init(reason: String) {
		self.reason = reason
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (_ , sentences) = try? wordsAndSentences(for: description, wordCount: 0, sentenceCount: 1) else {
			return nil
		}
		self.reason = sentences[0]
	}
	
	func execute(on connection: Connection) {
		connection.receivedError(.loginDenied(reason: reason))
	}
	
	var description: String {
		return "DENIED \(reason)"
	}
}


/**
Sent in response to a REGISTER command, if registration has been refused.
*/
struct SCRegistrationDeniedCommand: SCCommand {
	
	let reason: String
	
	// MARK: - Manual Construction
	
	init(reason: String) {
		self.reason = reason
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (_, sentences) = try? wordsAndSentences(for: description, wordCount: 0, sentenceCount: 1) else {
			return nil
		}
		self.reason = sentences[0]
	}
	
	func execute(on connection: Connection) {
		connection.receivedError(.registrationDenied(reason: reason))
	}
	
	var description: String {
		return "REGISTRATIONDENIED \(reason)"
	}
}


/**
Sent in response to a REGISTER command, if registration has been accepted.

If email verification is enabled, sending of this command notifies that the server has sent a verification code to the users email address. This verification code is expected back from the client in CONFIRMAGREEMENT

Upon reciept of this command, a lobby client would normally be expected to reply with a LOGIN attempt (but this is not a requirement of the protocol).
*/
struct SCRegistrationAcceptedCommand: SCCommand {
	
	// MARK: - Manual Construction
	
	init() {}
	
	// MARK: - SCCommand
	
	init?(description: String) {}
	
	func execute(on connection: Connection) {
		#warning("Display some kind of success")
	}
	
	var description: String {
		return "REGISTRATIONACCEPTED"
	}
}


struct SCLoginInfoEndCommand: SCCommand {
	
	// MARK: - Manual Construction
	
	init() {
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
	}
	
	func execute(on connection: Connection) {
	}
	
	var description: String {
		return "LOGININFOEND"
	}
}


struct SCAgreementCommand: SCCommand {
	
	let agreement: String
	
	// MARK: - Manual Construction
	
	init(agreement: String) {
		self.agreement = agreement
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (_, sentences) = try? wordsAndSentences(for: description, wordCount: 0, sentenceCount: 1) else {
			return nil
		}
		self.agreement = sentences[0]
	}
	
	func execute(on connection: Connection) {
		#warning("Update agreement")
	}
	
	var description: String {
		return "AGREEMENT \(agreement)"
	}
}


struct SCAgreementEndCommand: SCCommand {
	
	// MARK: - Manual Construction
	
	init() {
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
	}
	
	func execute(on connection: Connection) {
		#warning("Display agreement now")
	}
	
	var description: String {
		return "AGREEMENTEND"
	}
}


struct SCChangeEmailRequestAcceptedCommand: SCCommand {
	
	// MARK: - Manual Construction
	
	init() {
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
	}
	
	func execute(on connection: Connection) {
		#warning("Should display some kind of success here")
	}
	
	var description: String {
		return "CHANGEEMAILREQUESTACCEPTED"
	}
}


struct SCChangeEmailRequestDeniedCommand: SCCommand {
	
	let errorMessage: String
	
	// MARK: - Manual Construction
	
	init(errorMessage: String) {
		self.errorMessage = errorMessage
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (_, sentences) = try? wordsAndSentences(for: description, wordCount: 0, sentenceCount: 1) else {
			return nil
		}
		self.errorMessage = sentences[0]
	}
	
	func execute(on connection: Connection) {
		connection.receivedError(.changeEmailRequestDenied(errorMessage: errorMessage))
	}
	
	var description: String {
		return "CHANGEEMAILREQUESTDENIED \(errorMessage)"
	}
}


struct SCChangeEmailAcceptedCommand: SCCommand {
	
	// MARK: - Manual Construction
	
	init() {
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
	}
	
	func execute(on connection: Connection) {
		#warning("Should display some kind of success here")
	}
	
	var description: String {
		return "CHANGEEMAILACCEPTED"
	}
}


struct SCChangeEmailDeniedCommand: SCCommand {
	
	let errorMessage: String
	
	// MARK: - Manual Construction
	
	init(errorMessage: String) {
		self.errorMessage = errorMessage
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (_, sentences) = try? wordsAndSentences(for: description, wordCount: 0, sentenceCount: 1) else {
			return nil
		}
		self.errorMessage = sentences[0]
	}
	
	func execute(on connection: Connection) {
		connection.receivedError(.changeEmailDenied(errorMessage: errorMessage))
	}
	
	var description: String {
		return "CHANGEEMAILDENIED \(errorMessage)"
	}
}


struct SCResendVerificationAcceptedCommand: SCCommand {
	
	// MARK: - Manual Construction
	
	init() {
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		#warning("Should display some kind of success here")
	}
	
	func execute(on connection: Connection) {
	}
	
	var description: String {
		return "RESENDVERIFICATIONACCEPTED"
	}
}


struct SCResendVerificationDeniedCommand: SCCommand {
	
	let errorMessage: String
	
	// MARK: - Manual Construction
	
	init(errorMessage: String) {
		self.errorMessage = errorMessage
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (_, sentences) = try? wordsAndSentences(for: description, wordCount: 0, sentenceCount: 1) else {
			return nil
		}
		self.errorMessage = sentences[0]
	}
	
	func execute(on connection: Connection) {
		connection.receivedError(.resendVerificationDenied(errorMessage: errorMessage))
	}
	
	var description: String {
		return "RESENDVERIFICATIONDENIED \(errorMessage)"
	}
}

struct SCResetPasswordRequestAcceptedCommand: SCCommand {

	
	// MARK: - Manual Construction
	
	init() {
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
	}
	
	func execute(on connection: Connection) {
		#warning("Should display some kind of success here")
	}
	
	var description: String {
		return "RESETPASSWORDREQUESTACCEPTED"
	}
}

struct SCResetPasswordRequestDeniedCommand: SCCommand {
	
	let errorMessage: String
	
	// MARK: - Manual Construction
	
	init(errorMessage: String) {
		self.errorMessage = errorMessage
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (_, sentences) = try? wordsAndSentences(for: description, wordCount: 0, sentenceCount: 1) else {
			return nil
		}
		self.errorMessage = sentences[0]
	}
	
	func execute(on connection: Connection) {
		connection.receivedError(.resetPasswordRequestDenied(errorMessage: errorMessage))
	}
	
	var description: String {
		return "RESETPASSWORDREQUESTDENIED \(errorMessage)"
	}
}


/**
 Notifies that client that their password was changed, in response to RESETPASSWORD. The new password will be emailed to the client.
*/
struct SCResetPasswordAcceptedCommand: SCCommand {
	
	// MARK: - Manual Construction
	
	init() {}
	
	// MARK: - SCCommand
	
	init?(description: String) {}
	
	func execute(on connection: Connection) {
		#warning("Should display some kind of success here")
	}
	
	var description: String {
		return "RESETPASSWORDACCEPTED"
	}
}


struct SCResetPasswordDeniedCommand: SCCommand {
	
	let errorMessage: String
	
	// MARK: - Manual Construction
	
	init(errorMessage: String) {
		self.errorMessage = errorMessage
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (_, sentences) = try? wordsAndSentences(for: description, wordCount: 0, sentenceCount: 1) else {
			return nil
		}
		errorMessage = sentences[0]
	}
	
	func execute(on connection: Connection) {
		connection.receivedError(.resetPasswordDenied(errorMessage: errorMessage))
	}
	
	var description: String {
		return "RESETPASSWORDDENIED \(errorMessage)"
	}
}

