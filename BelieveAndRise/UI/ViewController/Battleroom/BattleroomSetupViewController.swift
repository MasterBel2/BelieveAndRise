//
//  BattleroomSetupViewController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 28/7/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa

class BattleroomSetupViewController: NSViewController {
    @IBOutlet var titleField: NSTextField!
    @IBOutlet var gameSelectionBox: NSPopUpButton!
    @IBOutlet var engineSelectionBox: NSPopUpButton!
    @IBOutlet var descriptionField: NSTextField!
    @IBOutlet var showRestrictionsMenu: NSButton!
    @IBOutlet var restrictionsLabel: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.font = .boldSystemFont(ofSize: 22.0)
        titleField.stringValue = "Configure Battleroom"
    }
    
}
