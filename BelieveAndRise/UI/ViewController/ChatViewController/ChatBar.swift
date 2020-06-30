//
//  ChatBar.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 8/9/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

protocol ChatBarDelegate: AnyObject {
    func chatBar(_ chatBar: ChatBar, shouldSendMessage message: String) -> Bool
}

final class ChatBar: NSView, NibLoadable {

    // MARK: - Dependencies

    weak var delegate: ChatBarDelegate?

    // MARK: - Lifecycle

    override func loadedFromNib() {
        padding = ChatBar.defaultInsets
    }

    // MARK: - UI Components

    @IBOutlet var textField: NSTextField!
    @IBOutlet var button: NSButton!

    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var leadingConstraint: NSLayoutConstraint!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet var trailingConstraint: NSLayoutConstraint!

    var padding: NSEdgeInsets! {
        didSet {
            bottomConstraint.constant = padding.bottom
            leadingConstraint.constant = padding.left
            topConstraint.constant = padding.top
            trailingConstraint.constant = padding.right
        }
    }

    static let defaultInsets = NSEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)

    // MARK: - NSControl

    var isEnabled: Bool {
        set {
            textField.isEnabled = newValue
            button.isEnabled = newValue
        }
        get {
            return textField.isEnabled && button.isEnabled
        }
    }


    // MARK: - Actions

    @IBAction func sendMessage(_ sender: Any) {

        if let delegate = delegate,
            delegate.chatBar(self, shouldSendMessage: textField.stringValue) {
            textField.stringValue = ""
        }
    }
}
