//
//  ExtendedChatMessageView.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 30/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

final class ExtendedChatMessageView: NSView, NibLoadable {
    @IBOutlet var timeLabel: NSTextField!
    @IBOutlet var clanTagField: NSTextField!
    @IBOutlet var usernameField: NSTextField!
    @IBOutlet var messageField: NSTextField!
}
