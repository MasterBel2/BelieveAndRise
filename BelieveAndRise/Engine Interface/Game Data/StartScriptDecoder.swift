//
//  GameSpecificationDecoder.swift
//  ReplayParser
//
//  Created by MasterBel2 on 20/6/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// Converts an engine start script into a `GameSpecification` object.
final class GameSpecificationDecoder {
    enum GameScriptError {

        /// The decoder didn't find an expected character.
        struct ExpectedCharacter: LocalizedError, CustomStringConvertible {
            let character: Character

            var description: String {
                return "Expected character \"\(character)\""
            }
        }
        /// An extraneous character was parsed.
        struct UnexpectedCharacter: LocalizedError, CustomStringConvertible {
            let character: Character

            var description: String {
                return "Unexpected character \"\(character)\""
            }
        }
        /// The script has an incorrect format.
        struct IncorrectFormat: LocalizedError, CustomStringConvertible {
            let reason: String

            var description: String {
                return "Incorrect format: \(reason)"
            }
        }
    }

    /// Converts the script to a `GameSpecification` object.
    func decode(_ script: String) throws -> GameSpecification {

        // Find bracket pairs
        let pairs = try findBracketPairs(in: script)
        // Map into sections
        var sections: [String : [String : String]] = [:]
        for (index, pair) in pairs.enumerated() {
            let otherPairs = pairs.filter({ $0 != pairs[index]})
            if pair.title.lowercased() == "game" {
                if !otherPairs.reduce(true, { $0 && pairs[index].contains($1) }) {
                    throw GameScriptError.IncorrectFormat(reason: "Game section does not contain section titled \"\(pairs[index].title)\".")
                }
            } else {
                if !(otherPairs.reduce(true, { $0 && (!pairs[index].contains($1) || pair.title.lowercased() == "game") })) {
                    throw GameScriptError.IncorrectFormat(reason: "Section titled \"\(pair.title)\" should not contain any other sections.")
                }
            }
            sections[pair.title.lowercased()] = try findArguments(between: pair, in: script, otherPairs: otherPairs)
        }

        return try GameSpecification(sections: ScriptSections(value: sections))
    }

    /// Describes a matching pair of braces in the start script.
    struct Pair: Equatable {
        let opening: String.Index
        let closing: String.Index

        let title: Substring

        init(opening: String.Index, closing: String.Index, sourceString: String) throws {
            self.opening = opening
            self.closing = closing
            self.title = try sectionTitle(before: opening, in: sourceString)
        }

        /// Whether another pair is located within this pair's bounds.
        func contains(_ other: Pair) -> Bool {
            return self.closing > other.closing && self.opening < other.opening
        }
    }

    /// Locates matching pairs of braces in the start script.
    private func findBracketPairs(in string: String) throws -> [Pair] {
        var openings: [String.Index] = []
        var pairs: [Pair] = []
        var startIndex = string.startIndex

        search: while let closingIndex = string[startIndex...].firstIndex(of: "}") {
            if let openingIndex = string[startIndex...].firstIndex(of: "{"),
                openingIndex < closingIndex {
                openings.append(openingIndex)
                startIndex = string.index(after: openingIndex)
            } else if openings.count > 0 {
                startIndex = string.index(after: closingIndex)
                let openingIndex = openings.removeLast()
                let newPair = try Pair(opening: openingIndex, closing: closingIndex, sourceString: string)
                pairs.append(newPair)
            } else {
                throw GameScriptError.ExpectedCharacter(character: "{")
            }
        }
        return pairs
    }

    /// The name of the section directly before the given index.
    private static func sectionTitle(before startIndex: String.Index, in text: String) throws -> Substring {
        var searchBeforeIndex = startIndex
        // Index of close bracket
        guard let closeIndex = text[...searchBeforeIndex].lastIndex(of: "]") else { throw GameScriptError.ExpectedCharacter(character: "]") }
        searchBeforeIndex = text.index(before: closeIndex)
        guard let openingIndex = text[...searchBeforeIndex].lastIndex(of: "[") else { throw GameScriptError.ExpectedCharacter(character: "[") }
        return text[text.index(after: openingIndex)..<closeIndex]
    }

    /// Parses the values declared between the brackets, skipping values contained in another pair.
    private func findArguments(between bracketPair: Pair, in text: String, otherPairs: [Pair]) throws -> [String : String] {
        var startIndex = text.index(after: bracketPair.opening)
        var attributes: [String : String] = [:]
        search: while let (possibleKey, nextIndex) = try? read(until: "=", in: text, from: startIndex),
            nextIndex < bracketPair.closing {
            for otherPair in otherPairs {
                if bracketPair.contains(otherPair),
                    nextIndex > otherPair.opening && nextIndex < otherPair.closing {
                    startIndex = text.index(after: otherPair.closing)
                    continue search
                }
            }
            let (value, newNextIndex) = try read(until: ";", in: text, from: text.index(after: nextIndex))
            attributes[possibleKey.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()]
                = value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            startIndex = text.index(after: newNextIndex)
        }

        return attributes
    }

    /// Locates the next occurence of a character in a string.
    private func read(until endCharacter: Character, in text: String, from index: String.Index) throws -> (read: Substring, endIndex: String.Index) {
        guard let nextIndex = text[index...].firstIndex(of: endCharacter) else {
            throw GameScriptError.ExpectedCharacter(character: endCharacter)
        }
        let readCharacters = text[index..<nextIndex]
        // todo: Validation

        return (readCharacters, endIndex: nextIndex)
    }
}
