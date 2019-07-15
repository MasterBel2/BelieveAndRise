//
//  SingleColumnTableColumnRowView.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 25/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

final class SingleColumnTableColumnRowView: NSView, NibLoadable {
	
	// MARK: - Interface
	
	@IBOutlet weak var primaryLabel: NSTextField!
	@IBOutlet weak var secondaryLabel: NSTextField!
	
	override func awakeFromNib() {
		primaryLabel.textColor = .black
		primaryLabel.stringValue = ""
		secondaryLabel.textColor = .darkGray
		secondaryLabel.stringValue = ""
	}
}
