//
//  CastableAsComparable.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 8/8/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/// A set of functions allowing instances of a type to be generically sorted by properties, made available by the keys specified by the implementing type.
protocol Sortable {
	/// A type containing a list of keys that may indicate a type's property. Used for operations such as sorting.
    associatedtype PropertyKey
	/// Compares the
    func relationTo(_ other: Self, forSortKey: PropertyKey) -> ValueRelation
}

/// A value indicating
enum ValueRelation {
	/// Indicates that the two values are equal.
    case equal
	/// Indicates the first value is greater than the second.
    case greater
	/// Indicates the second value is lesser than the first.
    case lesser

    init<T: Comparable>(value1: T, value2: T) {
        if value1 < value2 {
            self = .lesser
        } else if value1 == value2 {
            self = .equal
        } else {
            self = .greater
        }
    }
}
