//
//  GenericList.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 12/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

protocol Sorter {
    func `is`(valueFor id1: Int, greaterThanValueFor id2: Int) -> Bool
    func `is`(valueFor id1: Int, lessThanValueFor id2: Int) -> Bool
}

protocol GenericListDelegate {
    func genericList(_ genericList: GenericList, didAddItemAt index: Int)
    func genericList(_ genericList: GenericList, didRemoveItemAt index: Int)
}

class GenericList {
    // MARK: - Behaviour

    /// Determines whether updates to the list's parent (e.g. Addition, removal) should automatically True by default.
    ///
    /// If it is intended for this value to be false, ListItem should be a value type, as for reference types property changes
    /// will always be inherited.
    var automaticallyInheritParentUpdates: Bool = true

    // MARK: - Properties

    // Metadata

    /// A brief, human-readable string describing the content of the list
    let title: String

    var sorter: Sorter

    // Content

    //        /// A key value indicating by which property the list items should be sorted
    //        private(set) var sortKey: ListItem.PropertyKey
    /// An array of item IDs, sorted in the order determined by the values of the item's properties, as indicated by the sort key.
    ///
    /// This is a computed property, so avoid accessing more times than is necessary.
    private var sortedItemsByID: [Int] = []
    /// The items contained in the list, keyed by their ID.
    /// The locations of the items in the sorted list, keyed by their ID.
    private var itemIndicies: [Int : Int] = [:]

    // Structure

    /// The list of which this is a sublist.
    let parent: GenericList?

    /// An array of lists that are a subset of this list.
    ///
    /// Displayed lists will often contain a subset of another list. Creating a list as a
    /// sublist of another list allows modifications happen to all sublists automatically.
    private(set) var sublists: [GenericList] = []

    // Thread safety

    private let queue: DispatchQueue

    // MARK: - Dependencies

    /// The List object's delegate.
    //    weak var delegate: ListDelegate?
    /// The List object's data source.
    //    weak var dataSource: ListDataSource?

    // MARK: - Lifecycle

    /// Creates a list with the given title, sorted by the given sort key
    init(title: String, sorter: Sorter, parent: GenericList? = nil) {
        self.title = title
        self.parent = parent
        self.sorter = sorter

        queue = DispatchQueue(label: title)
    }

    // MARK: - Computed Properties

    /// The number of items in the list
    var itemCount: Int {
        return sortedItemsByID.count
    }

    /// The ID of the item at the given location
    func itemID(at index: Int) -> Int? {
        return sortedItemsByID[index]
    }

    // MARK: - Mutating methods

    /// Inserts the item into the list, with the ID as its key, locating it according to the
    /// selected sorting method.
    func addItemWithID(_ id: Int) {
        queue.sync {
            self._addItemWithID(id)
        }
    }

    private func _addItemWithID(_ newItemId: Int) {
        for (index, id) in sortedItemsByID.enumerated() {
            if !sorter.is(valueFor: newItemId, greaterThanValueFor: id) {
                sortedItemsByID.insert(newItemId, at: index)
                itemIndicies[newItemId] = index
                itemIndicies[id] = index + 1
                return
            }
        }
    }

    /// An alias for `addItemWithID()` that ensures the item is present in the parent list.
    func addItemFromParent(id: Int) {
        queue.sync {
            if let parent = parent,
                parent.sortedItemsByID.contains(id) {
                _addItemWithID(id)
            }
        }
    }

    /// Removes the item with the given ID from the list.
    func removeItem(withID id: Int) {
        queue.sync {
            guard let index = self.itemIndicies[id] else {
                return
            }
            self.sortedItemsByID.remove(at: index)
            self.itemIndicies.removeValue(forKey: id)
            self.sublists.forEach { $0.removeItem(withID: id) }
        }
    }
}
