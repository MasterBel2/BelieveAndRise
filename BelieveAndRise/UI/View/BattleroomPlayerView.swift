//
//  BattleroomPlayerView.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 7/12/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

final class BattleroomPlayerView: NSView, NibLoadable {

    @IBOutlet var rankImageView: NSImageView!
    @IBOutlet var clanField: NSTextField!
    @IBOutlet var usernameField: NSTextField!

    // MARK: - Lifecycle

    override func loadedFromNib() {
        clanField.textColor = NSColor(named: "minorMajorLabel")
    }
}
