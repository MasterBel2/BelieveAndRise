//
//  UserAuthenticationController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 13/7/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation
import Cocoa

/// Stores a username and its associated password.
struct Credentials {
    let username: String
    let password: String
}

/// An error that may be returned when accessing the keychain.
enum KeychainError: Error {
    /// Indicates no password was stored for the website.
    case noPassword
    /// Indicates the data stored for the password could not be decoded.
    case unexpectedPasswordData
    /// Indicates an unspecified error.
    case unhandledError(status: OSStatus)
}

/// A convenient interface for the keychain, and the primary means of interacting with it.
final class CredentialsManager {
    private init() {}

    private static var _shared: CredentialsManager?
    static var shared: CredentialsManager {
        return _shared ?? {
            let credentialsManager = CredentialsManager()
            _shared = credentialsManager
            return credentialsManager
        }()
    }

    // MARK: - Accessing credentials

    /// Retrieves from the keychin the credentials associated with the server address.
    func credentials(forServerWithAddress serverAddress: String) throws -> Credentials {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: serverAddress,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }

        guard let existingItem = item as? [String : Any],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8),
            let account = existingItem[kSecAttrAccount as String] as? String
            else {
                throw KeychainError.unexpectedPasswordData
        }

        return Credentials(username: account, password: password)
    }

    // MARK: - Writing credentials

    /// Writes the credentials associated with the server address to the keychain.
    func writeCredentials(_ credentials: Credentials, forServerWithAddress serverAddress: String) throws {
        let account = credentials.username
        let password = credentials.password.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: account,
            kSecAttrServer as String: serverAddress,
            kSecValueData as String: password
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    }
}

/// A controller for the user authentication process.
final class UserAuthenticationController: UserAuthenticationViewControllerDelegate {

    // MARK: - Dependencies

    private var _viewController: UserAuthenticationViewController?
    let credentialsManager: CredentialsManager
    let server: TASServer

    // MARK: - Lifecycle

    init(server: TASServer) {
        self.server = server
        credentialsManager = CredentialsManager.shared
    }

    // MARK: - Presentation

    var viewController: NSViewController {
        return _viewController ?? {
            let userAuthenticationViewController = UserAuthenticationViewController()
            userAuthenticationViewController.delegate = self
            let request: IncompleteAuthenticateUserRequest

            do {
                let credentials = try credentialsManager.credentials(forServerWithAddress: server.socket.address)
                request = IncompleteAuthenticateUserRequest(username: credentials.username, password: credentials.password, email: nil)
            } catch {
                print(error)
                request = IncompleteAuthenticateUserRequest.empty
            }
            userAuthenticationViewController.configureFor(request)
            _viewController = userAuthenticationViewController
            return userAuthenticationViewController
        }()
    }

    // MARK: -

    func loginDidSucceed() {
        
    }

    // MARK: - UserAuthenticationViewControllerDelegate

    func login(for userAuthenticationViewController: UserAuthenticationViewController) {
        #warning("Hard-coded data")
        let username = "BelieveAndRise"
        let password = "Believe"

        //
        do {
            #warning("fails if credentials are already written")
            try credentialsManager.writeCredentials(Credentials(username: username, password: password), forServerWithAddress: server.socket.address)
        } catch {
            #warning("Error invisible to user")
            print(error)
        }

        server.send(LoginCommand(username: username, password: password))
    }
}
