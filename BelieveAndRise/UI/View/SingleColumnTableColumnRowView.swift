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

    func loadedFromNib() {
        primaryLabel.textColor = .labelColor
        primaryLabel.stringValue = ""
        secondaryLabel.textColor = .secondaryLabelColor
        secondaryLabel.stringValue = ""
    }
}
