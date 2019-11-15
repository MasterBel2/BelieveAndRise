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
    mutating func moveItem(from oldIndex: Int, to newIndex: Int) {
        let value = self[oldIndex]
        remove(at: oldIndex)
        insert(value, at: newIndex)
    }
}
