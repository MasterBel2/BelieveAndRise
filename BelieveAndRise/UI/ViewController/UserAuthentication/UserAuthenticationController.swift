//
//  UserAuthenticationController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 13/7/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

struct LoginError: LocalizedError, CustomStringConvertible {
    let description: String
}

/// A controller for the user authentication process.
final class UserAuthenticationController: LoginDelegate {

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
    let windowManager: ClientWindowManager
    /// The server for the authentication attempt is being made.
    let server: TASServer

    /// A string that uniquely identifies the server
    private var serverDescription: String {
        return "\(server.socket.address):\(server.socket.port)"
    }

    // MARK: - Lifecycle

    init(server: TASServer, windowManager: ClientWindowManager, preferencesController: PreferencesController) {
        self.server = server
        self.windowManager = windowManager
        self.preferencesController = preferencesController
        credentialsManager = CredentialsManager.shared
    }

    // MARK: - LoginDataSource

    var prefillableUsernames: [String] {
        return (try? credentialsManager.usernames(forServerWithAddress: serverDescription)) ?? []
    }

    var lastCredentialsPair: Credentials? {
        if let lastUsername = preferencesController.lastUsername(for: serverDescription) {
            return try? credentialsManager.credentials(forServerWithAddress: serverDescription, username: lastUsername)
        }
        return nil
    }

    // MARK: - LoginDelegate

    func submitLogin(username: String, password: String, completionHandler: @escaping (Result<String, LoginError>) -> Void) {
        server.send(
            CSLoginCommand(
                username: username,
                password: password,
                compatabilityFlags: [
                    .sayForBattleChatAndSayFrom,
                    .springEngineVersionAndNameInBattleOpened,
                    .lobbyIDInAddUser,
                    .joinBattleRequestAcceptDeny,
                    .scriptPasswords
                ]
            ),
            specificHandler: { [weak self] (command: SCCommand) in
                guard let self = self else { return }
                if let loginAcceptedCommand = command as? SCLoginAcceptedCommand {
                    self.recordLoginInformation(username: loginAcceptedCommand.username, password: password)
                    completionHandler(.success(loginAcceptedCommand.username))
                } else if let loginDeniedCommand = command as? SCLoginDeniedCommand {
                    completionHandler(.failure(LoginError(description: loginDeniedCommand.reason)))
                } else {
                    completionHandler(.failure(LoginError(description: "A server error occured.")))
                }
            }
        )
    }

    func submitRegister(username: String, email: String, password: String, completionHandler: @escaping (String?) -> Void) {
        server.send(
            CSRegisterCommand(
                username: username,
                password: password
            ),
            specificHandler: { [weak self] (command: SCCommand) in
                guard let self = self else { return }
                if command is SCRegistrationAcceptedCommand {
                    completionHandler(nil)
                    self.submitLogin(
                        username: username,
                        password: password,
                        completionHandler: { result in
                            switch result {
                            case .success:
                                break
                            case .failure(let error):
                                fatalError("Login failed: \(error.description)")
                            }
                        }
                    )
                } else if let deniedCommand = command as? SCRegistrationDeniedCommand {
                    completionHandler(deniedCommand.reason)
                } else {
                    completionHandler("A server error occured.")
                }
            }
        )
    }

    private func recordLoginInformation(username: String, password: String) {
        preferencesController.setLastUsername(username, for: serverDescription)
        self.username = username
        self.password = password
        try? credentialsManager.writeCredentials(
            Credentials(username: username, password: password), forServerWithAddress: serverDescription
        )
    }
}
