//
//  ListViewController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 24/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

/**
 A view controller wrapping a single-column table view that displays a sectioned list of
 information.
*/
class ListViewController: NSViewController,
                            ListDisplay, ListDelegate,
                            NSTableViewDelegate, NSTableViewDataSource {
	
	// MARK: - Nested Types
	
	/// Represents the data for a header or item in a list view controller's table view.
	///
	/// List view controllers can display sections which consist of a header and a
	/// number of items. Use the .header case to represent a header, and the .item case
	/// to represent a section's item.
	private enum Row {
		/// Represents a list section header.
		case header(String)
		/// Represents a list item. Stores the item's ID.
		case item(Int)
	}

    // MARK: - Configuration

    /// Determines whether the content rows should be selectable.
    var displaysSelectableContent: Bool = true

    /// Whether cells should be displayed for the section headers. Automatically updates the table view on a value update.
    var shouldDisplaySectionHeaders: Bool = true {
        willSet {
            if !shouldDisplaySectionHeaders && newValue {
                sections.reversed().forEach({
                    let index = offset(forSectionNamed: $0.title)
                    rows.insert(.header($0.title), at: index)
                    if isViewLoaded {
                        tableView.insertRows(at: IndexSet(integer: 0), withAnimation: .effectFade)
                    }
                })
            } else if shouldDisplaySectionHeaders && !newValue {
                sections.forEach({
                    let index = offset(forSectionNamed: $0.title) - 1
                    rows.remove(at: index)
                    if isViewLoaded {
                        tableView.removeRows(at: IndexSet(integer: 0), withAnimation: .effectFade)
                    }
                })
            }
        }
    }

    /// Whether header cells are displayed with the the number of rows in the section prefixed to the section title. Has no effect when
    /// `shouldDisplaySectionHeaders == false`.
    var shouldDisplayRowCountInHeader: Bool = true {
        didSet {
            if isViewLoaded && shouldDisplaySectionHeaders {
                var offset = 0
                for section in sections {
                    tableView.reloadData(forRowIndexes: IndexSet(integer: offset), columnIndexes: IndexSet(integer: 0))
                    offset += section.itemCount + 1
                }
            }
        }
    }

    /// Provides views for rows corresponding to items.
	///
	/// Views are automatically reloaded when the view provider changes.
    var itemViewProvider: ItemViewProvider = DefaultItemViewProvider() {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }

    override var nibName: NSNib.Name? {
        return "ListViewController"
    }
	
	// MARK: - Dependencies
	
	/// The list view controller's delegate.
	weak var delegate: ListViewControllerDelegate?
	/// The list view controller's data source.
	weak var dataSource: ListViewControllerDataSource?
	/// The list's selection handler.
	var selectionHandler: ListSelectionHandler?
	
	// MARK: - Interface
	
	/// The table view in which the data will be displayed.
    @IBOutlet var tableView: NSTableView!
    /// Organises the vertical arrangement of the interface.
    ///
    /// The elements in this stack view should not be directly manipulated. The last element in the
    /// stack view is returned as the footer, if one has been set.
    @IBOutlet var stackView: NSStackView!

	// MARK: - Data
	
	/// An array of rows that corresponds to the rows displayed by the table view.
	///
	/// Rows may be either displayed as a header or an item.
	private var rows: [Row] = []

	/// The lists that provide the data for each of the sections.
    private(set) var sections: [ListProtocol] = []

	// MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.reloadData()
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
    }

    // MARK: - Accessories

    private(set) var hasFooter = false
	
    /// Returns the list's footer, or nil if one has not been set.
    var footer: NSView? {
        get {
            return hasFooter ? stackView.arrangedSubviews.last : nil
        }
        set {
            if hasFooter {
                if footer == newValue { return }
                stackView.removeView(stackView.arrangedSubviews.last!)
            }
            // We don't have to worry if the footer is nil, because the previous footer has
            if let newFooter = newValue {
                stackView.addArrangedSubview(newFooter)
                hasFooter = true
            } else {
                hasFooter = false
            }
        }
    }

	/// Creates a header for the given section.
    private func header(for list: ListProtocol) -> Row {
        if shouldDisplayRowCountInHeader {
            return .header(list.title + " (\(list.itemCount))")
        } else {
            return .header(list.title)
        }
    }

    // MARK: - ListDisplay

	/// Adds a section to the view, if it has not already been added.
    func addSection(_ list: ListProtocol) {
        executeOnMain(target: self) {
            guard !sections.contains(where: { $0 === list }) else {
                return
            }

            list.delegate = $0
            $0.sections.append(list)
            if $0.shouldDisplaySectionHeaders && list.itemCount > 0 {
                $0.rows.append(.header(list.title))
            }
            $0.rows.append(contentsOf: list.sortedItemsByID.map({ Row.item($0) }))

            if isViewLoaded {
                let rangeOfItems = indexRange(forSection: list)
                for index in IndexSet(integersIn: rangeOfItems) {
                    $0.tableView.insertRows(
                        at: IndexSet(integer: index),
                        withAnimation: .effectFade
                    )
                }

            }
        }
    }

    /// Removes a section from the view.
    func removeSection(_ list: ListProtocol) {
        executeOnMain(target: self) {
            guard sections.contains(where: { $0 === list }) else {
                return
            }
            list.delegate = nil
            let rangeOfItems = self.indexRange(forSection: list)
            // We need to know the section's order in the array to calculate the indexes.
            $0.sections = $0.sections.filter({ $0 !== list })
            rangeOfItems.forEach({ _ = rows.remove(at: $0)} )

            if isViewLoaded {
                $0.tableView.removeRows(
                    at: IndexSet(integersIn: rangeOfItems),
                    withAnimation: .effectFade
                )
            }
        }
    }

    /// Returns the range of indexes corresponding to the list's items in the array of rows.
    private func indexRange(forSection section: ListProtocol) -> Range<Int> {
        guard section.itemCount > 0 else {
            // If there are no items, we don't display the header.
            return 0..<0
        }
        let offsetDueToHeader = (shouldDisplaySectionHeaders && section.itemCount > 0 ? 1 : 0)
        let startIndex = offset(forSectionNamed: section.title) - offsetDueToHeader
        let endIndex = startIndex + section.itemCount + offsetDueToHeader
        return startIndex..<endIndex
    }

    /// Calculates the offset for the first item in the section, such that the first item is at offset `offset`, the second at `offset + 1`, and the section header (if it should be displayed) at `offset - 1`.
    private func offset(forSectionNamed sectionName: String) -> Int {
        var count = 0
        for section in sections {
            if shouldDisplaySectionHeaders && section.itemCount > 0 {
                count += 1
            }
            if section.title == sectionName {
                return count
            }
            count += section.itemCount
        }
        fatalError("Section \(sectionName) doesn't exist!")
    }
    

    // MARK: - ListDelegate

    func list(_ list: ListProtocol, didAddItemWithID id: Int, at index: Int) {
        executeOnMain(target: self) { viewController in
            let sectionOffset = viewController.offset(forSectionNamed: list.title)
            // When adding the first item, we also need to add the header. Because the item is
            // already in the list, we check for == 1 (the first item) rather than == 0
            if  shouldDisplaySectionHeaders {
                if list.itemCount == 1 {
                    rows.insert(header(for: list), at: sectionOffset - 1)
                    viewController.tableView.insertRows(
                        at: IndexSet(integer: sectionOffset - 1),
                        withAnimation: .effectFade
                    )
                } else if shouldDisplayRowCountInHeader {
                    viewController.rows[sectionOffset - 1] = header(for: list)
                    viewController.tableView.reloadData(
                        forRowIndexes: IndexSet(integer: sectionOffset - 1),
                        columnIndexes: IndexSet(integer: 0)
                    )
                }
            }

            viewController.rows.insert(.item(id), at: sectionOffset + index)
            viewController.tableView.insertRows(at: IndexSet(integer: sectionOffset + index), withAnimation: .effectFade)
        }
    }

    func list(_ list: ListProtocol, didRemoveItemAt index: Int) {
        executeOnMain(target: self) { viewController in
            let sectionOffset = viewController.offset(forSectionNamed: list.title)
            viewController.rows.remove(at: sectionOffset + index)
            viewController.tableView.removeRows(at: IndexSet(integer: sectionOffset + index), withAnimation: .effectFade)

            if list.itemCount > 0 {
                viewController.rows[sectionOffset - 1] = header(for: list)
            } else {
                // Don't subtract one from the section offset as it has already been adjusted -1 for the lack of a header
                viewController.rows.remove(at: sectionOffset)
                viewController.tableView.removeRows(at: IndexSet(integer: sectionOffset), withAnimation: .effectFade)
            }
        }
    }

    func list(_ list: ListProtocol, itemWasUpdatedAt index: Int) {
        executeOnMain(target: self) { viewController in
            viewController.tableView.reloadData(
                forRowIndexes: IndexSet(integer: viewController.offset(forSectionNamed: list.title) + index),
                columnIndexes: IndexSet(integer: 0)
            )
        }
    }

    func list(_ list: ListProtocol, didMoveItemFrom index1: Int, to index2: Int) {
        executeOnMain(target: self) { viewController in
            let sectionOffset = viewController.offset(forSectionNamed: list.title)

            let from = sectionOffset + index1
            let to = sectionOffset + index2
            viewController.rows.moveItem(from: from, to: to)
            viewController.tableView.moveRow(at: from, to: to)
        }
    }
	
	// MARK: - NSTableViewDelegate
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		switch rows[row] {
		case .header(let title):
			let view = TableSectionHeaderView.loadFromNib()
			view.label.stringValue = title
			return view
		case .item(let id):
			return itemViewProvider.view(forItemIdentifiedBy: id)
		}
	}
	
	func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
		return NSTableRowView()
	}
	
	func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		switch rows[row] {
		case .header(_):
			return false
		case .item(let id):
			selectionHandler?.primarySelect(itemIdentifiedBy: id)
			return displaysSelectableContent && true
		}
	}
	
	// MARK: - NSTableViewDataSource
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return rows.count
	}

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        guard let view = self.tableView(tableView, viewFor: tableView.tableColumns[0], row: row) else {
            // Returning 0 results in a crash, so we'll return 0 instead
            return 1
        }

        view.widthAnchor.constraint(equalToConstant: tableView.frame.width).isActive = true
        view.layoutSubtreeIfNeeded()
        return view.fittingSize.height
    }
}
