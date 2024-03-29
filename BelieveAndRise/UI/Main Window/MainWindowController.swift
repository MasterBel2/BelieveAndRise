//
//  MainWindowController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 5/9/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa
import UberserverClientCore

final class MainWindowController: NSWindowController {

    // MARK: - Dependencies

    weak var client: Client?
    weak var authenticatedClient: AuthenticatedSession?

    /// The controller for storing and retrieving interface-related defaults.
    var defaultsController: InterfaceDefaultsController!

    // MARK: - Data

    /// The primary list acts as a navigation
    let battlelistViewController = ListViewController()
    let chatViewController = ChatViewController()
    let userListViewController = ListViewController()

    private(set) var battleroomViewController: BattleroomViewController?

    private var splitViewController: NSSplitViewController!

    // MARK: - Toolbar Items

    @IBAction func toggleSidebarCollapsed(_ sender: Any) {
        splitViewController.splitViewItems[0].animator().isCollapsed = !splitViewController.splitViewItems[0].isCollapsed
    }

    func configure(for authenticatedClient: AuthenticatedSession) {
        self.authenticatedClient = authenticatedClient
        battlelistViewController.addSection(authenticatedClient.battleList)
        battlelistViewController.itemViewProvider = BattlelistItemViewProvider(list: authenticatedClient.battleList)
        battlelistViewController.selectionHandler = DefaultBattleListSelectionHandler(
            client: authenticatedClient,
            battlelist: authenticatedClient.battleList
        )

        userListViewController.addSection(authenticatedClient.userList)
        userListViewController.itemViewProvider = PlayerRankIngameUsernameItemViewProvider(playerList: authenticatedClient.userList)

        chatViewController.authenticatedClient = authenticatedClient
    }

    func deconfigure() {
        battlelistViewController.removeAllSections()
        userListViewController.removeAllSections()
    }

    // MARK: - MainWindowController

    /**
     Displays a battleroom and configures it with the information that should be already populated.
     */
    func displayBattleroom(_ battleroom: Battleroom) {
        executeOnMain { [weak self] in
            self?._displayBattleroom(battleroom)
        }
    }

    private func _displayBattleroom(_ battleroom: Battleroom) {
        let battleroomViewController = self.battleroomViewController ?? BattleroomViewController()
        battleroomViewController.session = authenticatedClient.map({ // We'll just assume here that if we have a session, we have a client
            MakeUnownedQueueLocked(lockedObject: $0, queue: client!.connection!._connection.queue)
        })
        battleroomViewController.setBattleroom(battleroom)
        let middleSplitViewItem = splitViewController.splitViewItems[1]
        if middleSplitViewItem.viewController !== battleroomViewController {
            splitViewController.removeSplitViewItem(middleSplitViewItem)
            splitViewController.insertSplitViewItem(
                NSSplitViewItem(viewController: battleroomViewController),
                at: 1
            )
        }

        battleroomViewController.chatViewController.authenticatedClient = authenticatedClient

        self.battleroomViewController = battleroomViewController

        battlelistViewController.footer = leaveBattleButton
    }

    func destroyBattleroomViewController() {
        executeOnMain { [weak self] in
            self?._destroyBattleroomViewController()
        }
    }

    private func _destroyBattleroomViewController() {
        guard let battleroomViewController = battleroomViewController,
              let battleroomSplitViewItem = splitViewController.splitViewItem(for: battleroomViewController) else {
            return
        }
        self.battleroomViewController = nil
        splitViewController.removeSplitViewItem(battleroomSplitViewItem)
        splitViewController.insertSplitViewItem(NSSplitViewItem(viewController: chatViewController), at: 1)
    }

    // MARK: - Presentation

    override var windowNibName: NSNib.Name? {
        return "MainWindowController"
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        
        battlelistViewController.footer = hostBattleButton

        // Load user's preferred sidebar widths.

        battlelistViewController.view.setFrameSize(
            CGSize(
                width: defaultsController.defaultBattlelistSidebarWidth,
                height: battlelistViewController.view.frame.height
            )
        )
        userListViewController.view.setFrameSize(
            CGSize(
                width: defaultsController.defaultPlayerListSidebarWidth,
                height: userListViewController.view.frame.height
            )
        )

        // Create content split view.

        let splitViewController = newSplitViewController()
        window?.contentViewController = splitViewController
        self.splitViewController = splitViewController

        // Customise appearance.

        chatViewController.setViewBackgroundColor(.controlBackgroundColor)
    }

    let leaveBattleButton = NSButton(title: "Leave Battle", target: self, action: #selector(leaveBattle))
    let hostBattleButton = NSButton(title: "Host Battle", target: self, action: #selector(MacOSClientWindowManager.openBattle(_:)))

    /// Creates a new split view controller to control the content.
    ///
    /// By default, items for the battlelist, chat, and userlist are added to the split view controller.
    /// A resize delegate is set to track the user's preferred sidebar widths.
    private func newSplitViewController() -> NSSplitViewController {
        let viewController = ResizeTrackingSplitViewController()
        viewController.resizeDelegate = MainSplitViewControllerResizeDelegate(
            battlelistViewController: battlelistViewController,
            playerlistViewController: userListViewController,
            interfaceDefaultsController: defaultsController
        )

        viewController.addItems(forViewControllers: [battlelistViewController, chatViewController, userListViewController])
        
        // Make the middle element (non-sidebar) accept all extra width by default
        viewController.splitViewItems[1].holdingPriority = .init(rawValue: 249)

        return viewController
    }

    // MARK: - Actions

    /// An action to be triggered when a user wishes to leave a battleroom.
    ///
    /// After the battleroom is destroyed, the notification that the user wishes to leave the battle is sent to the server.
    @objc private func leaveBattle() {
        destroyBattleroomViewController()
        authenticatedClient?.leaveBattle()
        battlelistViewController.footer = hostBattleButton
        // Deselect the battle so the player may re-select it.
        battlelistViewController.tableView.deselectAll(nil)
    }
}
