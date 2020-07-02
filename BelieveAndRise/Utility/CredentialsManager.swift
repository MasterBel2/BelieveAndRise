//
//  CredentialsManager.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 14/12/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

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

    /// Retrieves all usernames associated with the server from the keychain.
    func usernames(forServerWithAddress serverAddress: String) throws -> [String] {

        // Create a keychain query for the first username & password match for the server.
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: serverAddress,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecReturnAttributes as String: true
        ]

        // Retrieve the query result.
        var queryResponse: CFTypeRef?
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &queryResponse)

        // Check for errors.
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }

        guard let result = queryResponse as? [[String : Any]] else {
            throw KeychainError.unexpectedData
        }
        return result.compactMap({ $0[kSecAttrAccount as String] as? String })
    }

    /// Retrieves from the keychain the credentials associated with a given username and server address.
    func credentials(forServerWithAddress serverAddress: String, username: String) throws -> Credentials {

        // Create a keychain query for the first username & password match for the server.
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: serverAddress,
            kSecAttrAccount as String: username,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]

        // Retrieve the query result.
        var queryResponse: CFTypeRef?
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &queryResponse)

        // Check for errors.
        guard status != errSecItemNotFound else {
            throw KeychainError.noPassword
        }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }

        guard let result = queryResponse as? Data else {
            throw KeychainError.unexpectedData
        }

        guard let password = String(data: result, encoding: String.Encoding.utf8) else {
            throw KeychainError.unexpectedData
        }

        return Credentials(username: username, password: password)
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
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }
}
