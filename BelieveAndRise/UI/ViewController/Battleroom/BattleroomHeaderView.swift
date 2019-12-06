//
//  BattleroomHeaderView.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 30/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

/**
 A set of delegate functions for the `BattleroomHeaderView`.
 */
protocol BattleroomHeaderViewDelegate: AnyObject {
    func startGame()
}

/// The header view for a battleroom, containing basic controls and information.
final class BattleroomHeaderView: NSVisualEffectView, NibLoadable {

    // MARK: - Interface

    @IBOutlet var minimapView: MinimapView!
    @IBOutlet var hostNameField: NSTextField!
    @IBOutlet var hostClanField: NSTextField!
    @IBOutlet var battleDescriptionField: NSTextField!
    @IBOutlet var mapNameField: NSTextField!

    @IBOutlet var watchGameButton: NSButton!

    @IBOutlet var allySelectorPopupButton: NSPopUpButton!
    @IBOutlet var syncStatusLabel: NSTextField!

    // MARK: - Dependencies

    /// The battleroom header view's delegate.
    weak var delegate: BattleroomHeaderViewDelegate?

    // MARK: - Lifecycle

    override func loadedFromNib() {
        allySelectorPopupButton.removeAllItems()
    }

    // MARK: - Data

    /// An item which corresponds to an option in the `BattleroomHeaderView.allySelectorPopupButton`.
    struct AllyItem {
        let title: String
        let action: () -> Void
    }

    /// The displayed ally items.
    private(set) var allyItems: [AllyItem] = []

    /// Adds an option to the displayed list of items.
    func addAllyItem(_ allyItem: AllyItem) {
        allyItems.append(allyItem)
        allySelectorPopupButton.addItem(withTitle: allyItem.title)
    }

    /// Inserts an option into the displayed list of items.
    func insertAllyItem(_ allyItem: AllyItem, at index: Int) {
        allyItems.insert(allyItem, at: index)
        allySelectorPopupButton.insertItem(withTitle: allyItem.title, at: index)
    }

    /// Removes the option corresponding to the ally item name from the displayed list of items.
    func removeAllyItem(named itemName: String) {
        allyItems.removeAll(where: {$0.title == itemName})
        allySelectorPopupButton.removeItem(withTitle: itemName)
    }

    // MARK: - Receiving control actions

    @IBAction func beginWatchingGame(_ sender: Any) {
        delegate?.startGame()
    }

    @IBAction func newSectionSelected(_ sender: NSPopUpButton) {
        allyItems[sender.indexOfSelectedItem].action()
    }

    // MARK: - Setting control states

    /// Sets a state for the watch game button.
    ///
    /// See `WatchGameButtonState` for more information.
    func setWatchGameButtonState(_ state: WatchGameButtonState) {
        switch state {
        case .enabled:
            watchGameButton.isHidden = false
            enableWatchGameButton()
        case .disabled:
            watchGameButton.isHidden = false
            disableWatchGameButton()
        case .hidden:
            watchGameButton.isHidden = true
        }
    }

    func displaySyncStatus(_ synced: Bool) {
        if synced {
            syncStatusLabel.stringValue = "Synced"
            syncStatusLabel.textColor = NSColor(named: "userIsAlly")
        } else {
            syncStatusLabel.stringValue = "Unsynced"
            syncStatusLabel.textColor = NSColor(named: "userIsEnemy")
        }
    }

    // MARK: - Private helpers

    // Possible states:
    // - Ingame
    // - Spectator (Spectator/Player)
    // - Ready (Ready/unready, Spectator/Player)
    // - Unready (Ready/unready, Spectator/Player)

    private func disableWatchGameButton() {
        watchGameButton.image = nil
        watchGameButton.title = "Ingame"
        watchGameButton.isEnabled = false
    }

    private func enableWatchGameButton() {
        watchGameButton.image = NSImage(named: "NSFollowLinkFreestandingTemplate")
        watchGameButton.title = "Watch Game"
        watchGameButton.isEnabled = true
    }

    enum WatchGameButtonState {
        /// The state associated with the host being ingame and the player being out of game.
        case enabled
        /// The state associated with the player and host being ingame.
        case disabled
        /// The state associated with the host being out of game.
        case hidden
    }
}
