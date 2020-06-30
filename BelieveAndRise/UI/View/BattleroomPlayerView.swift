//
//  BattleroomPlayerView.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 7/12/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

/// Displays information about a player in a format designed for the battleroom's player list.
final class BattleroomPlayerView: NSView, NibLoadable {

	/// Displays the user's rank.
    @IBOutlet var rankImageView: RankView!
	/// Displays the user's clan.
    @IBOutlet var clanField: NSTextField!
	/// Displays the user's username.
    @IBOutlet var usernameField: NSTextField!

    // MARK: - Lifecycle

    override func loadedFromNib() {
        clanField.textColor = NSColor(named: "minorMajorLabel")
    }
}
