//
//  StartScriptError.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 28/7/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// The decoder couldn't find as many values as specified by a key.
struct IncorrectCount: LocalizedError, CustomStringConvertible {
    let key: String

    var description: String {
        return "Incorrect number of values corresponding to key \"\(key)\""
    }
}

/// A necessary script section was absent.
struct MissingScriptSection: LocalizedError, CustomStringConvertible {
    let section: ScriptSections.Section

    var description: String {
        return "Missing script section \"\(section.description)\""
    }
}

/// A necessary script argument was absent.
struct MissingScriptArgument: LocalizedError, CustomStringConvertible {
    let section: ScriptSections.Section
    let key: String

    var description: String {
        return "Missing value for script argument \"\(key)\" in section \"\(section.description)\""
    }
}

/// A correctly typed yet invalid value was parsed.
struct InvalidValueForScriptArgument<T>: LocalizedError, CustomStringConvertible {
    let section: ScriptSections.Section
    let key: String
    let value: T

    var description: String {
        return "Invalid value \"\(value)\" for script argument \"\(key)\" in section \"\(section.description)\""
    }
}

/// A value of an unexpected type was parsed.
struct IncorrectValueTypeScriptArgument<T>: LocalizedError, CustomStringConvertible {
    let section: ScriptSections.Section
    let key: String
    let expectedType: T.Type

    var description: String {
        return "Invalid value type for script argument \"\(key)\" in section \"\(section.description)\". Expected type \"\(expectedType)\""
    }
}

