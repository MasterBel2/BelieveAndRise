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

    /// Retrieves from the keychin the credentials associated with the server address.
    func credentials(forServerWithAddress serverAddress: String) throws -> Credentials {

        // Create a keychain query for the first username & password match for the server.
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: serverAddress,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]

        // Retrieve the query result.
        var item: CFTypeRef?
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &item)

        // Check for errors.
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }

        // (Check password data & Account name is valid.)
        guard let existingItem = item as? [String : Any],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8),
            let accountName = existingItem[kSecAttrAccount as String] as? String
            else {
                throw KeychainError.unexpectedPasswordData
        }

        return Credentials(username: accountName, password: password)
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
