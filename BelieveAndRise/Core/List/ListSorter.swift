//
//  ListSorter.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 26/7/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// Idenifies a magnitude relationship between two items in a list.
protocol ListSorter {
    func relation(betweenItemIdentifiedBy id1: Int, shouldAppearBeforeItemIdentifiedBy id2: Int) -> ValueRelation
}

/// Sorts a list of players in a battleroom according to their trueskills.
final class BattleroomPlayerListSorter: ListSorter {
    weak var battleroom: Battleroom?

    func relation(betweenItemIdentifiedBy id1: Int, shouldAppearBeforeItemIdentifiedBy id2: Int) -> ValueRelation {
        guard let trueSkill1 = battleroom?.trueSkill(for: id1),
            let trueSkill2 = battleroom?.trueSkill(for: id2) else {
    return .lesser
        }
        return ValueRelation(value1: trueSkill1, value2: trueSkill2)
    }
}

/// Sorts a list according to the sort key, which provides access to the item's properties.
final class SortKeyBasedSorter<ListItem: Sortable>: ListSorter {
    weak var list: List<ListItem>?
    let sortKey: ListItem.PropertyKey
    init(sortKey: ListItem.PropertyKey) {
        self.sortKey = sortKey
    }

    func relation(betweenItemIdentifiedBy id1: Int, shouldAppearBeforeItemIdentifiedBy id2: Int) -> ValueRelation {
        guard let item1 = list?.items[id1],
            let item2 = list?.items[id2] else {
                return .equal
        }
        return item1.relationTo(item2, forSortKey: sortKey)
    }
}

/// Sorts a list according to the property provided by the closure.
final class PropertySorter<ListItem, Property: Comparable>: ListSorter {
    weak var list: List<ListItem>?
    let property: (ListItem) -> Property

    init(property: @escaping (ListItem) -> Property) {
        self.property = property
    }
    func relation(betweenItemIdentifiedBy id1: Int, shouldAppearBeforeItemIdentifiedBy id2: Int) -> ValueRelation {
        guard let item1 = list?.items[id1],
            let item2 = list?.items[id2] else {
                return .equal
        }
        return ValueRelation(value1: property(item1), value2: property(item2))
    }
}
