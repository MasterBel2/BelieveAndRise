//
//  ListSorter.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 26/7/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

protocol ListSorter {
    func relation(betweenItemIdentifiedBy id1: Int, shouldAppearBeforeItemIdentifiedBy id2: Int) -> ValueRelation
}

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
