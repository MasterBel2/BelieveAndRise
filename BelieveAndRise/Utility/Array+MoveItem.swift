//
//  Array+MoveItem.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 14/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

extension Array {
    /// Removes an item from its current index in the array and places it at the new index.
    mutating func moveItem(at oldIndex: Int, to newIndex: Int) {
        let value = self[oldIndex]
        if oldIndex > newIndex {
            remove(at: oldIndex)
            insert(value, at: newIndex)
        } else {
            insert(value, at: newIndex)
            remove(at: oldIndex)
        }
    }
}
