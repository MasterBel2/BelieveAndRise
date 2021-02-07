//
//  InterfaceDefaultsController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 3/2/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// An object that stores information about custom UI configuration.
final class InterfaceDefaultsController {

    private let userDefaults = UserDefaults.standard
    private let defaultSidebarWidth: CGFloat = 200

    /// The customised value for the width of the main window's battlelist sidebar.
    ///
    /// Returns the default sidebar width if the user has not modified the sidebar's width.
    var defaultBattlelistSidebarWidth: CGFloat {
        get {
            return value(for: .battlelistSidebarWidth) ?? defaultSidebarWidth
        }
        set {
            setValue(newValue, for: .battlelistSidebarWidth)
        }
    }

    var defaultChatSidebarWidth: CGFloat {
        get {
            return value(for: .chatSidebarWidth) ?? defaultSidebarWidth
        }
        set {
            setValue(newValue, for: .chatSidebarWidth)
        }
    }

    /// The customised value for the width of the main window's playerlist sidebar.
    ///
    /// Returns the default sidebar width if the user has not modified the sidebar's width.
    var defaultPlayerListSidebarWidth: CGFloat {
        get {
            return value(for: .playerlistSidebarWidth) ?? defaultSidebarWidth
        }
        set {
            setValue(newValue, for: .playerlistSidebarWidth)
        }
    }

    /// Retrieves a value from the user defaults, as indexed under a key. Returns nil if no value has been stored, or if the value stored was of an incorrect type.
    private func value<ValueType>(for key: DefaultsKeys) -> ValueType? {
        return userDefaults.value(forKey: key.rawValue) as? ValueType
    }

    /// Stores a value in the user defaults, indexed under a key.
    private func setValue(_ value: Any?, for key: DefaultsKeys) {
        userDefaults.setValue(value, forKey: key.rawValue)
    }

    /// A set of keys for values stored in the user defaults.
    private enum DefaultsKeys: String {
        /// The key associated with the preffered width of the battlelist in the main window.
        case battlelistSidebarWidth
        /// The key associated with the preffered width of the playerlist in the main window.
        case playerlistSidebarWidth
        case chatSidebarWidth
    }
}
