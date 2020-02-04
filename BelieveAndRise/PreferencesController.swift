//
//  PreferencesController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 16/12/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/// An object that provides an API for persisting data about the user's preferences.
final class PreferencesController {

	/// The standard user defaults object.
    private let userDefaults = UserDefaults.standard
	
	/// The player's preferred color.
    var preferredColor: Int32 {
        get {
            return value(for: .playerColor) ?? 0
        }
        set {
            setValue(newValue, for: .playerColor)
        }
    }

    /// Records the username as most recently used to log in to the server.
    func setLastUsername(_ username: String, for serverName: String) {
        let key = serverAttributeKey(for: serverName, attributeKey: .lastUsername)
        userDefaults.setValue(username, forKey: key)
    }
    /// Returns the username most recently used to log in to the server.
    func lastUsername(for serverName: String) -> String? {
        let key = serverAttributeKey(for: serverName, attributeKey: .lastUsername)
        return userDefaults.value(forKey: key) as? String
    }
	
	// MARK: - Private helpers

    private func serverAttributeKey(for serverAddress: String, attributeKey: ServerAttributeKey) -> String {
        return serverAddress + ":" + attributeKey.rawValue
    }

	/// Retrives the previously recorded value for the given key.
    private func value<ValueType>(for key: DefaultsKeys) -> ValueType? {
        return userDefaults.value(forKey: key.rawValue) as? ValueType
    }

	/// Records a value for the given key.
    private func setValue(_ value: Any?, for key: DefaultsKeys) {
        userDefaults.setValue(value, forKey: key.rawValue)
    }

    private enum ServerAttributeKey: String {
        /// The key associated with the username most recently used to log in to a server.
            case lastUsername
    }
	
	/// A set of keys corresponding to preference values.
    private enum DefaultsKeys: String {
		/// The key associated with player's preferred color.
        case playerColor
    }
}
