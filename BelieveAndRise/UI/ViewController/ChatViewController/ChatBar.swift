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

/// Wraps an NSTextField with capabilities associated with sending messages.
final class ChatBar: NSView, NibLoadable, NSTextFieldDelegate, NSControlTextEditingDelegate {

    // MARK: - Dependencies

    weak var delegate: ChatBarDelegate?
    private var sentMessages: [String] = []
    private var messageCache: String = ""
    private var historyIndex: Int? = nil
    private var lookingAtHistory: Bool {
        historyIndex != nil
    }

    // MARK: - Lifecycle

    func loadedFromNib() {
        padding = ChatBar.defaultInsets
    }

    // MARK: - UI Components

    @IBOutlet var textField: NSTextField! {
        didSet {
            textField?.delegate = self
        }
    }
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
        let message = textField.stringValue

        if let delegate = delegate,
            delegate.chatBar(self, shouldSendMessage: message) {
            if sentMessages.first != message {
                sentMessages.insert(message, at: 0)
            }
            historyIndex = nil
            textField.stringValue = ""
        }
    }

    // MARK: - NSTextFieldDelegate

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        switch commandSelector {
        case #selector(moveUp(_:)):
            let newHistoryIndex: Int
            if let historyIndex = historyIndex {
                newHistoryIndex = historyIndex + 1
            } else {
                messageCache = textField.stringValue
                newHistoryIndex = 0
            }
            if newHistoryIndex < sentMessages.count {
                self.historyIndex = newHistoryIndex
                textField.stringValue = sentMessages[newHistoryIndex]
            }
        case #selector(moveDown(_:)):
            if let historyIndex = historyIndex {
                if historyIndex == 0 {
                    self.historyIndex = nil
                    textField.stringValue = messageCache
                } else {
                    let newHistoryIndex = historyIndex - 1
                    self.historyIndex = newHistoryIndex
                    textField.stringValue = sentMessages[newHistoryIndex]
                }
            }
        default:
            return false
        }
        return true
    }

    func controlTextDidChange(_ obj: Notification) {
        historyIndex = nil
    }
}
