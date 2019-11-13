//
//  List.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 16/7/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

protocol ListDelegate: AnyObject {
    /// Notifies the delegate that the list added an item with the given ID at the given index.
    func list(_ list: ListProtocol, didAddItemWithID id: Int, at index: Int)
    /// Notifies the delegate that the list removed an item at the given index.
    func list(_ list: ListProtocol, didRemoveItemAt index: Int)
    /// Notifies the delegate that the list moved an item between the given indices.
    func list(_ list: ListProtocol, itemWasUpdatedAt index: Int)
    /// Notifies the delegate that the list moved an item between the given indices.
    func list(_ list: ListProtocol, didMoveItemFrom index1: Int, to index2: Int)
}

protocol ListDataSource: AnyObject {

}

// This is a concept class name, commented out so it doesn't show up in autocomplete.
// The concept is that all lists that are a subset of the primary list should have the same sorting,
// therefore they all should be sorted in the one place – the head. Of course, this functionality
// doesn't need a separate class to be implemented. if let parent = parent { … }. It's just a
// prompt.

//final class ListHead<ListItem: Sortable>: List<ListItem> {}

protocol ListProtocol: AnyObject {
    var title: String { get }
    var itemCount: Int { get }
    var delegate: ListDelegate? { get set }
	var sortedItemsByID: [Int] { get }
}

/// A list wraps a set of objects by their ID.
final class List<ListItem: Sortable>: ListProtocol {

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

    // Content

    /// A key value indicating by which property the list items should be sorted
    private(set) var sortKey: ListItem.PropertyKey
    /// An array of item IDs, sorted in the order determined by the values of the item's properties, as indicated by the sort key.
    private(set) var sortedItemsByID: [Int] = []
    /// The items contained in the list, keyed by their ID.
    private(set) var items: [Int : ListItem] = [:]
    /// The locations of the items in the sorted list, keyed by their ID.
    private var itemIndicies: [Int : Int] = [:]

    // Structure

    /// The list of which this is a sublist.
    private(set) weak var parent: List<ListItem>?

    /// An array of lists that are a subset of this list.
    ///
    /// Displayed lists will often contain a subset of another list. Creating a list as a
    /// sublist of another list allows modifications happen to all sublists automatically.
    private(set) var sublists: [List<ListItem>] = []

    // Thread safety

    private let queue: DispatchQueue

    // MARK: - Dependencies

    /// The List object's delegate.
	var delegate: ListDelegate?
    /// The List object's data source.
	weak var dataSource: ListDataSource?

    // MARK: - Lifecycle

    /// Creates a list with the given title, sorted by the given sort key
    init(title: String, sortKey: ListItem.PropertyKey, parent: List<ListItem>? = nil) {
        self.title = title
        self.sortKey = sortKey
        self.parent = parent

        queue = DispatchQueue(label: title)
    }

    // MARK: - Retrieving list data

    /// The number of items in the list
    var itemCount: Int {
        return items.count
    }

    /// The ID of the item at the given location
    func itemID(at index: Int) -> Int? {
        guard (0..<itemCount).contains(index) else {
            return nil
        }
        return sortedItemsByID[index]
    }

    func item(at index: Int) -> ListItem? {
        guard let itemID = self.itemID(at: index) else {
            return nil
        }
        return items[itemID]
    }

    // MARK: - Updating list content

    /// Inserts the item into the list, with the ID as its key, locating it according to the
    /// selected sorting method.
    func addItem(_ item: ListItem, with id: Int) {
        queue.sync {
            self._addItem(item, with: id)
        }
    }

    /// A helper function ensuring an item is in the parent list before
    func addItemFromParent(id: Int) {
        queue.sync {
            if let item = self.parent?.items[id] {
                self._addItem(item, with: id)
            }
        }
    }

    private func _addItem(_ item: ListItem, with id: Int) {
        for index in 0..<itemCount {
            let idAtIndex = sortedItemsByID[index]
            guard let itemAtIndex = items[idAtIndex] else {
                return
            }
            if item.relationTo(itemAtIndex, forSortKey: sortKey) != .greater {
				itemIndicies[idAtIndex] = index + 1
				placeItem(item, with: id, at: index)
                return
            }
        }
		placeItem(item, with: id, at: itemCount)
    }

    /// Places an item in the list and sets its indexes etc. Does not update the item that it is overwriting
    private func placeItem(_ item: ListItem, with id: Int, at index: Int) {
        items[id] = item
        sortedItemsByID.insert(id, at: index)
        itemIndicies[id] = index
        delegate?.list(self, didAddItemWithID: id, at: index)
    }

    /// Updates the list's sort order and notifies the delegate that the item has been updated.
    func respondToUpdatesOnItem(identifiedBy id: Int) {
        queue.sync {
            guard let index = self.itemIndicies[id],
                let updatedItem = item(at: index) else {
                return
            }

            var indexesToUpdate: [Int] = []
            var newIndex = index

            for (relation, offset) in [(ValueRelation.lesser, 1), (ValueRelation.greater, -1)] {
                while let otherItem = item(at: newIndex + offset),
                    updatedItem.relationTo(otherItem, forSortKey: sortKey) == relation {
                        indexesToUpdate.append(index)
                        newIndex += offset
                }

                if newIndex != index {
                    sortedItemsByID.moveItem(at: index, to: newIndex)
                    indexesToUpdate.forEach({
                        if let currentIndex = itemIndicies[$0] {
                            itemIndicies[$0] = currentIndex + offset
                        }
                    })
                    delegate?.list(self, didMoveItemFrom: index, to: newIndex)
                    break
                }
            }
            delegate?.list(self, itemWasUpdatedAt: newIndex)
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
            self.items.removeValue(forKey: id)
            self.sublists.forEach { $0.removeItem(withID: id) }

            self.delegate?.list(self, didRemoveItemAt: index)
        }
    }
}
