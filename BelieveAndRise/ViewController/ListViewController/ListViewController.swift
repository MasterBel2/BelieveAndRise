//
//  ListViewController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 24/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

/**
A view controller wrapping a single-column table view that displays a sectioned list of information.
*/
final class ListViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
	
	// MARK: - Nested Types
	
	/// Represents the data for a header or item in a list view controller's table view.
	///
	/// List view controllers can display sections which consist of a header and a
	/// number of items. Use the .header case to represent a header, and the .item case
	/// to represent a section's item.
	private enum Row {
		/// Represents a list section header.
		case header(String)
		/// Represents a list item.
		case item((String, String))
	}
	
	// MARK: - Dependencies
	
	/// The list view controller's delegate.
	weak var delegate: ListViewControllerDelegate?
	/// The list view controller's data source.
	weak var dataSource: ListViewControllerDataSource?
	
	// MARK: - Interface
	
	/// The table view in which the data will be displayed.
	let tableView = NSTableView()
	
	// MARK: - Data
	
	/// An array of rows that corresponds to the rows displayed by the table view.
	///
	/// Rows may be either displayed as a header or an item.
	private var rows: [Row] = []
	
	// MARK: - Lifecycle
	
	override func loadView() {
		let tableView = NSTableView()
		
		tableView.autoresizingMask = [.width, .height]
		tableView.usesAutomaticRowHeights = true
		
		tableView.delegate = self
		tableView.dataSource = self
		
		tableView.addTableColumn(NSTableColumn())
		
		view = tableView
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.reloadData()
    }
	
	// MARK: - Data
	
	/// Sets the data to the table header.
	func setTableHeaderData(_ tableHeaderData: TableHeaderData) {
		#warning("Stub implementation")
		let headerView = NSTableHeaderView()
		tableView.headerView = headerView
	}
	
	/// Sets the table view's data and reloads it, so that the sections will be displayed
	/// on-screen.
	///
	/// - parameter sections: The list sections to be displayed in the table view.
 	func setTableSections(_ sections: [ListTableSection]) {
		var rows = [Row]()
		
		for section in sections {
			rows.append(.header(section.title))
			section.entries.forEach {
				rows.append(.item(($0.primaryTitle, $0.secondaryTitle)))
			}
		}
		self.rows = rows
		
		tableView.reloadData()
	}
	
	// MARK: - NSTableViewDelegate
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		switch rows[row] {
		case .header(let title):
			let view = TableSectionHeaderView.loadFromNib()
			view.label.stringValue = title
			return view
		case .item(let (primaryTitle, secondaryTitle)):
			let view = SingleColumnTableColumnRowView.loadFromNib()
			view.primaryLabel.stringValue = primaryTitle
			view.secondaryLabel.stringValue = secondaryTitle
			return view
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
		case .item(_):
			return true
		}
	}
	
	// MARK: - NSTableViewDataSource
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return rows.count
	}
}

struct ListTableSection {
	let title: String
	let entries: [ListTableEntry]
}

struct ListTableEntry {
	let primaryTitle: String
	let secondaryTitle: String
}
