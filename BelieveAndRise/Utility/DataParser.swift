//
//  DataParser.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 28/7/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// Interprets data made up of a set of raw values.
final class DataParser {

    /// A set of errors  thrown by `DataParser`
    enum Error: Swift.Error {
        /// Attempted to parse past the end of the data.
        case outOfBounds
    }

    /// The number of parsed bytes.
    private(set) var currentIndex: Int

    /// The data to parse from.
    let data: Data

    init(data: Data) {
        self.data = data
        self.currentIndex = data.startIndex
    }

    /// Compares the next value to the given value and advances the index by the stride of the type.
    ///
    /// - returns: true if the next value in the data matches the given value.
    func checkValue<T: Equatable>(expect: T) throws -> Bool {
        let actual = try parseData(ofType: T.self)
        return actual == expect
    }

    /// Compares the next n values to an array of length n and advances the index by n * the stride of the type.
    ///
    /// - returns: true if the next n values in the data match the values in an array.
    func checkValue<T: Equatable>(expect: Array<T>) throws -> Bool {
        let actual = try parseData(ofType: T.self, count: expect.count)
        return actual == expect
    }

    /// Reads n consecutive values of type T from the data and advances the index by n* the stride of the type.
    ///
    /// - returns: the extracted values in an array.
    ///
    /// - parameter type: The type of the value to be read.
    /// - parameter count: The number of values to read.
    func parseData<T>(ofType type: T.Type, count: Int) throws -> Array<T> {
        var temp = Array<T>()
        for _ in 0..<count {
            let x = try! parseData(ofType: type)
            temp.append(x)
        }
        return temp
    }

    /// Reads a value from the next available bytes and advances the index by the stride of the type.
    ///
    /// - parameter type: The type
    func parseData<T>(ofType: T.Type) throws -> T {
        let storageSize = MemoryLayout<T>.stride
        let endIndex = currentIndex + storageSize
        if endIndex <= data.endIndex {
            let temp = Data(data[currentIndex..<endIndex])
            currentIndex = endIndex
            return withUnsafePointer(to: temp) { pointer in
                pointer.withMemoryRebound(to: T.self, capacity: 1) {
                    return $0.pointee
                }
            }
        }
        throw Error.outOfBounds
    }
}
