//
//  TableSectionHeaderView.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 25/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

final class TableSectionHeaderView: NSView, NibLoadable {
	
	// MARK: - Interface
	
	@IBOutlet weak var label: NSTextField!
	
	// MARK: - Lifecycle
	
	override func awakeFromNib() {
		label.textColor = .darkGray
		label.stringValue = ""
	}
}
