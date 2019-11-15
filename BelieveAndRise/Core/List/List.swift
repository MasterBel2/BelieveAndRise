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
    /// An array of item IDs, sorted in the order determined by the values of the item's properties, as indicated by the sort key. `itemIndicies` and `items` must be updated before updating this array.
    private(set) var sortedItemsByID: [Int] = [] {
        didSet {
            #if DEBUG
            validateList()
            #endif
        }
    }
    /// The items contained in the list, keyed by their ID.
    private(set) var items: [Int : ListItem] = [:]
    /// The locations of the items in the sorted list, keyed by their ID.
    private(set) var itemIndicies: [Int : Int] = [:]

    // MARK: - Structure

    /// The list of which this is a sublist.
    private(set) weak var parent: List<ListItem>?

    /// An array of lists that are a subset of this list.
    ///
    /// Displayed lists will often contain a subset of another list. Creating a list as a
    /// sublist of another list allows modifications happen to all sublists automatically.
    private(set) var sublists: [List<ListItem>] = []

    // MARK: - Thread safety

    let queue: DispatchQueue

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
            if item.relationTo(itemAtIndex, forSortKey: sortKey) != .lesser {
                // Update the location of the items this displaces. Must happen before we sort the
                // so that we can identify them by their current location.
                for indexToUpdate in index..<itemCount {
                    let idToUpdate = sortedItemsByID[indexToUpdate]
                    itemIndicies[idToUpdate] = indexToUpdate + 1
                }
				placeItem(item, with: id, at: index)
                return
            }
        }
		placeItem(item, with: id, at: itemCount)
    }

    /// Places an item in the list and sets its indexes etc. Does not update the items that it displaces.
    private func placeItem(_ item: ListItem, with id: Int, at index: Int) {
        items[id] = item
        itemIndicies[id] = index
        sortedItemsByID.insert(id, at: index)
        delegate?.list(self, didAddItemWithID: id, at: index)
    }

    /// Updates the list's sort order and notifies the delegate that the item has been updated.
    func respondToUpdatesOnItem(identifiedBy id: Int) {
        queue.sync {
            guard let index = self.itemIndicies[id],
                let updatedItem = item(at: index) else {
                return
            }

            // ID : Position
            var indexesToUpdate: [Int] = []
            var newIndex = index

            for (relation, offset) in [(ValueRelation.lesser, 1), (ValueRelation.greater, -1)] {
                while let otherItem = item(at: newIndex + offset),
                    updatedItem.relationTo(otherItem, forSortKey: sortKey) == relation {
                        // the new value for newIndex is the position we're going to move into, so
                        // that's the item that will be displaced.
                        newIndex += offset
                        // Remember the index needs to be updated later. We won't update the dictionary yet since
                        // we're not actually moving things in sortedItemsByID yet.
                        indexesToUpdate.append(newIndex)
                }

                if newIndex != index {
                    // Update indexes associated with IDs before updating IDs associated with indexes, because it depends on the array
                    // -1 * offset, since they move the opposite direction to the updated item
                    indexesToUpdate.forEach({
                        itemIndicies[sortedItemsByID[$0]] = $0 - offset
                    })
                    // Update the index associated with the updated ID
                    itemIndicies[id] = newIndex
                    debugOnlyPrint("List: Moving item \(id) from \(index) to \(newIndex)")
                    sortedItemsByID.moveItem(from: index, to: newIndex)
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
            self.itemIndicies.removeValue(forKey: id)
            for indexToUpdate in (index + 1)..<itemCount {
                let idToUpdate = sortedItemsByID[indexToUpdate]
                itemIndicies[idToUpdate] = indexToUpdate - 1
            }
            self.items.removeValue(forKey: id)
            self.sortedItemsByID.remove(at: index)
            self.sublists.forEach { $0.removeItem(withID: id) }

            self.delegate?.list(self, didRemoveItemAt: index)
        }
    }

    // MARK: - List integrity

    /// Checks whether `itemIndicies` and `sortedItemsByID` agree, and prints an error message to the console if an inconsistency is detected
    private func validateList() {
        var valid = true
        items.forEach({
            let key = $0.key
            if let position = itemIndicies[$0.key] {
                let itemAtPosition = sortedItemsByID[position]

                if key != itemAtPosition {
                    valid = false
                }
            } else {
                valid = false
            }
        })

        if !valid {
            debugOnlyPrint("Internal inconsistency detected in list \(title): \(self)")
            items.map({
                let key = $0.key
                if let position = itemIndicies[$0.key] {
                    let itemAtPosition = sortedItemsByID[position]
                    return "Item \($0.key): Position \(position), ItemAtPosition \(itemAtPosition), valid: \(key == itemAtPosition)"
                } else {
                    return "Item \($0.key): Position: nil, valid: false"
                }
            }).forEach({ debugOnlyPrint($0)})
        }
    }
}
