//
//  UserAuthenticationController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 13/7/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

protocol UserAuthenticationDisplay: AnyObject {
    func displayAuthenticateUserRequest(_ request: IncompleteAuthenticateUserRequest)
}

/// A controller for the user authentication process.
final class UserAuthenticationController: UserAuthenticationControllerDisplayDelegate {

    // MARK: - Data

    var username: String?

    // MARK: - Dependencies

    let credentialsManager: CredentialsManager
    let windowManager: WindowManager
    let server: TASServer

    weak var display: UserAuthenticationDisplay? {
        didSet {
            prepareDisplay()
        }
    }

    // MARK: - Lifecycle

    init(server: TASServer, windowManager: WindowManager) {
        self.server = server
        self.windowManager = windowManager
        credentialsManager = CredentialsManager.shared
    }

    // MARK: - Presentation

    func prepareDisplay() {
        let request: IncompleteAuthenticateUserRequest

        do {
            let credentials = try credentialsManager.credentials(forServerWithAddress: server.socket.address)
            request = IncompleteAuthenticateUserRequest(username: credentials.username, password: credentials.password, email: nil)
        } catch {
            print(error)
            request = IncompleteAuthenticateUserRequest.empty
        }

        display?.displayAuthenticateUserRequest(request)
    }

    // MARK: - 

    func loginDidSucceed(for username: String) {
        self.username = username
        windowManager.dismissLogin()
    }

    // MARK: - UserAuthenticationViewControllerDelegate

    /// Takes the username and password from the fields 'username' and 'password' and sends a login command.
    func submitLogin(for userAuthenticationViewController: UserAuthenticationViewController) {
        guard let usernameField = userAuthenticationViewController.fields.filter({ $0.key == .username }).first, let passwordField = userAuthenticationViewController.fields.filter({ $0.key == .password }).first else {
            return
        }
        let username = usernameField.field.stringValue
        let password = passwordField.field.stringValue

        do {
			#warning("fails if credentials are already written; implement a check, possibly just for whether the credentials were read")
            try credentialsManager.writeCredentials(
                Credentials(username: username, password: password),
                forServerWithAddress: server.socket.address
            )
        } catch {
            #warning("Error invisible to user")
            print(error)
        }

        server.send(
            CSLoginCommand(
                username: username,
                password: password,
                compatabilityFlags: [
                    .sayForBattleChatAndSayFrom,
                    .springEngineVersionAndNameInBattleOpened,
                    .lobbyIDInAddUser,
                    .joinBattleRequestAcceptDeny,
                    .scriptPasswords,
                ]
            )
        )
    }
}
