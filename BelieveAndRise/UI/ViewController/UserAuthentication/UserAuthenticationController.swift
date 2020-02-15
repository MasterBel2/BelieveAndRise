//
//  UserAuthenticationController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 13/7/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/// A set of methods for displaying information about the user authentication process.
protocol UserAuthenticationDisplay: AnyObject {
    func displayAuthenticateUserRequest(_ request: IncompleteAuthenticateUserRequest)
}

/// A controller for the user authentication process.
final class UserAuthenticationController: UserAuthenticationControllerDisplayDelegate {

    // MARK: - Data

    /// The username returned by the server after a successful login.
    var username: String?
    /// The password used in the most recent login attempt.
    var password: String?

    // MARK: - Dependencies

    /// The controller's interface with the keychain.
    let credentialsManager: CredentialsManager
    /// The controller's interface with user defaults.
    let preferencesController: PreferencesController
    /// The controller's interface with the UI.
    let windowManager: ConnectionWindowManager
    /// The server for the authentication attempt is being made.
    let server: TASServer

    /// A string that uniquely identifies the server
    private var serverDescription: String {
        return "\(server.socket.address):\(server.socket.port)"
    }

    /// The user authentication controller's outlet for UI events.
    weak var display: UserAuthenticationDisplay? {
        didSet {
            prepareDisplay()
        }
    }

    // MARK: - Lifecycle

    init(server: TASServer, windowManager: ConnectionWindowManager, preferencesController: PreferencesController) {
        self.server = server
        self.windowManager = windowManager
        self.preferencesController = preferencesController
        credentialsManager = CredentialsManager.shared
    }

    // MARK: - Presentation

    /// Instructs the display to present a request with automatically pre-filled username and password, retrieved from the keychain.
    func prepareDisplay() {
        let request: IncompleteAuthenticateUserRequest

        if let lastUsername = preferencesController.lastUsername(for: serverDescription) {
            do {
                let credentials = try credentialsManager.credentials(forServerWithAddress: serverDescription, username: lastUsername)
                request = IncompleteAuthenticateUserRequest(username: credentials.username, password: credentials.password, email: nil)
            } catch {
                print(error)
                request = IncompleteAuthenticateUserRequest.empty
            }
        } else {
            request = IncompleteAuthenticateUserRequest.empty
        }

        display?.displayAuthenticateUserRequest(request)
    }

    /// Completes the login process after a successful login.
    func loginDidSucceed(for username: String) {
        // Record username for auto-fill on next login
        preferencesController.setLastUsername(username, for: serverDescription)

        // Store logged-in username for access by other objects.
        self.username = username

        // Add password to keychain
        if let password = password {
            do {
                #warning("fails if credentials are already written; implement a check, possibly just for whether the credentials were read")
                try credentialsManager.writeCredentials(
                    Credentials(username: username, password: password), forServerWithAddress: serverDescription
                )
            } catch {
                #warning("Error invisible to user")
                print(error)
            }
        }

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
        self.password = password

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
