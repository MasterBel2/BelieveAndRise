//
//  KeychainError.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 14/12/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/// An error that may be returned when accessing the keychain.
enum KeychainError: Error {
    /// Indicates no password was stored for the website.
    case noPassword
    /// Indicates the data stored for the password could not be decoded.
    case unexpectedData
    /// Indicates an unspecified error.
    case unhandledError(status: OSStatus)
}
