//
//  ScriptSections.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 28/7/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// Wraps a dictionary containing a launch script's sections.
struct ScriptSections {
    let value: [String : [String : String]]

    /// The number of sections which have a title with a given prefix.
    func numberOfSections(withPrefix prefix: String) -> Int {
        return value.filter({ $0.key.hasPrefix(prefix.lowercased()) }).count
    }

    /// Gives a string value for an attribute in the "game" section.
    func game(key: String) throws -> String {
        return try keyedString(for: key, from: .game)
    }

    /// Gives the dictionary of values for the section with the given title.
    func sectionValues(_ section: Section) throws -> [String : String] {
        guard let values = value[section.description.lowercased()] else {
            throw MissingScriptSection(section: section)
        }
        return values
    }

    /// Retrieves the string value for an attribute.
    func keyedString(for key: String, from section: Section) throws -> String {
        guard let keyedValue = try sectionValues(section)[key.lowercased()] else {
            throw MissingScriptArgument(section: section, key: key)
        }
        return keyedValue
    }

    /// Retrieves the integer value for an attribute.
    func keyedInteger(for key: String, from section: Section) throws -> Int {
        guard let keyedInteger = try Int(keyedString(for: key, from: section)) else {
            throw IncorrectValueTypeScriptArgument(section: section, key: key, expectedType: Int.self)
        }
        return keyedInteger
    }

    /// Retrieves the float value for an attribute.
    func keyedFloat(for key: String, from section: Section) throws -> Float {
        guard let keyedFloat = try Float(keyedString(for: key, from: section)) else {
            throw IncorrectValueTypeScriptArgument(section: section, key: key, expectedType: Float.self)
        }
        return keyedFloat
    }

    /// Sections that occur in a start script.
    enum Section {
        case game
        case modOptions
        case mapOptions
        case player(number: Int)
        case ai(number: Int)
        case team(number: Int)
        case allyteam(number: Int)
        case restrictions

        /// The string title of the described section.
        var description: String {
            switch self {
            case .game:
                return "Game"
            case .modOptions:
                return "Modoptions"
            case .mapOptions:
                return "MapOptions"
            case .player(let number):
                return "Player\(number)"
            case .ai(let number):
                return "AI\(number)"
            case .team(let number):
                return "Team\(number)"
            case .allyteam(let number):
                return "AllyTeam\(number)"
            case .restrictions:
                return "Restrict"
            }
        }
    }
}
