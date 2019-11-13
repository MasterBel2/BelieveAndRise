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

    var shouldDisplayRowCountInHeader: Bool = true {
        didSet {
            if isViewLoaded {
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
            return .header("\(list.itemCount) " + list.title)
        } else {
            return .header(list.title)
        }
    }

    // MARK: - ListDisplay

	/// Adds a section to the list.
    func addSection(_ list: ListProtocol) {
        list.delegate = self
        sections.append(list)
        rows.append(.header(list.title))
		rows.append(contentsOf: list.sortedItemsByID.map({ Row.item($0) }))
        if isViewLoaded {
            tableView.reloadData()
        }
    }

    func removeSection(_ list: ListProtocol) {
        sections = sections.filter({ $0 !== list })
	}

	/// Calculates the offset for the first item in the section, such that the first item is at offset `offset`, the second at `offset + 1`, and the section header at `offset - 1`.
    private func offset(forSectionNamed sectionName: String) -> Int {
        var count = 0
        for section in sections {
            count += 1
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
            viewController.rows.insert(.item(id), at: sectionOffset + index)
            viewController.tableView.insertRows(at: IndexSet(integer: sectionOffset + index), withAnimation: .effectFade)

            viewController.rows[sectionOffset - 1] = .header("\(list.itemCount) " + list.title)
        }
    }

    func list(_ list: ListProtocol, didRemoveItemAt index: Int) {
        executeOnMain(target: self) { viewController in
            let sectionOffset = viewController.offset(forSectionNamed: list.title)
            viewController.rows.remove(at: sectionOffset + index)
            viewController.tableView.removeRows(at: IndexSet(integer: sectionOffset + index), withAnimation: .effectFade)

            viewController.rows[sectionOffset - 1] = header(for: list)
        }
    }

    func list(_ list: ListProtocol, itemWasUpdatedAt index: Int) {
        executeOnMain(target: tableView) { tableView in
                        tableView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: IndexSet(integer: 0))
        }
    }

    func list(_ list: ListProtocol, didMoveItemFrom index1: Int, to index2: Int) {
        executeOnMain(target: self) { viewController in
            let sectionOffset = viewController.offset(forSectionNamed: list.title)

            let from = sectionOffset + index1
            let to = sectionOffset + index2
            viewController.rows.moveItem(at: from, to: to)
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
		let rowView = NSTableRowView()
		switch rows[row] {
		case .item(_):
			rowView.backgroundColor = .white
		default:
			break
		}
		return rowView
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
        return view.fittingSize.height
    }
}
