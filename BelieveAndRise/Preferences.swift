//
//  Preferences.swift
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
	
	// MARK: - Private helpers

	/// Retrives the previously recorded value for the given key.
    private func value<ValueType>(for key: DefaultsKeys) -> ValueType? {
        return userDefaults.value(forKey: key.rawValue) as? ValueType
    }

	/// Records a value for the given key.
    private func setValue(_ value: Any?, for key: DefaultsKeys) {
        userDefaults.setValue(value, forKey: key.rawValue)
    }
	
	/// A set of keys corresponding to preference values.
    private enum DefaultsKeys: String {
		/// The key associated with player's preferred color.
        case playerColor
    }
}
