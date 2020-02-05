//
//  MainWindowController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 5/9/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

final class MainWindowController: NSWindowController {

    // MARK: - Dependencies

    weak var connection: Connection?
    private weak var chatController: ChatController?
    private weak var battleController: BattleController?

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

    // MARK: - MainWindowController

    func displayBattlelist(_ battleList: List<Battle>) {
        guard let battleController = battleController else {
            debugOnlyPrint("No battle controller set!")
            return
        }
        battlelistViewController.sections.forEach(battlelistViewController.removeSection(_:))
        battlelistViewController.addSection(battleList)
        battlelistViewController.itemViewProvider = BattlelistItemViewProvider(list: battleList)
        battlelistViewController.selectionHandler = DefaultBattleListSelectionHandler(
            battlelist: battleList,
            battleController: battleController
        )
    }

    func displayServerUserlist(_ userList: List<User>) {
        userListViewController.sections.forEach(userListViewController.removeSection(_:))
        userListViewController.addSection(userList)
        userListViewController.itemViewProvider = DefaultPlayerListItemViewProvider(list: userList)
    }

    func displayChannel(_ channel: Channel) {
        chatViewController.setChannel(channel)
    }

    /**
     Displays a battleroom and configures it with the information that should be already populated
     */
    func displayBattleroom(_ battleroom: Battleroom) {

        // Set up view

        // Update data

        if let battleroomViewController = self.battleroomViewController {
            battleroomViewController.battleroom = battleroom
            let middleSplitViewItem = splitViewController.splitViewItems[1]
            if middleSplitViewItem.viewController !== battleroomViewController {
                splitViewController.removeSplitViewItem(middleSplitViewItem)
                splitViewController.insertSplitViewItem(
                    NSSplitViewItem(viewController: battleroomViewController),
                    at: 1
                )
            }
        } else {
            let battleroomViewController = BattleroomViewController()
            battleroomViewController.battleroom = battleroom
            battleroomViewController.battleController = battleController
            battleroomViewController.chatViewController.chatController = chatController
            splitViewController.removeSplitViewItem(splitViewController.splitViewItems[1])
            splitViewController.insertSplitViewItem(
                NSSplitViewItem(viewController: battleroomViewController),
                at: 1
            )
            battleroomViewController.setViewBackgroundColor(.controlBackgroundColor)
            self.battleroomViewController = battleroomViewController
        }

        leaveBattleButton.isHidden = false
    }

    func destroyBattleroom() {
        guard let battleroomViewController = battleroomViewController,
            let battleroomSplitViewItem = splitViewController.splitViewItem(for: battleroomViewController) else {
                return
        }
        self.battleroomViewController = nil
        splitViewController.removeSplitViewItem(battleroomSplitViewItem)
        splitViewController.insertSplitViewItem(NSSplitViewItem(viewController: chatViewController), at: 1)
    }

    func setChatController(_ chatController: ChatController) {
		chatViewController.chatController = chatController
        self.chatController = chatController
	}

    func setBattleController(_ battleController: BattleController) {
        self.battleController = battleController
    }

    // MARK: - Presentation

    override var windowNibName: NSNib.Name? {
        return "MainWindowController"
    }

    override func windowDidLoad() {
        super.windowDidLoad()

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

        window?.contentViewController?.addChild(splitViewController)
        window?.contentView?.addSubview(splitViewController.view)
        splitViewController.view.frame = window?.contentView?.frame ?? .zero
        splitViewController.view.autoresizingMask = [.width, .height]
        splitViewController.view.viewDidMoveToWindow()

        self.splitViewController = splitViewController

        // Customise appearance.

        chatViewController.setViewBackgroundColor(.controlBackgroundColor)

        leaveBattleButton.isHidden = true
        battlelistViewController.footer = leaveBattleButton
    }

    let leaveBattleButton = NSButton(title: "Leave Battle", target: self, action: #selector(leaveBattle))

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

        // Add view controllers to the split view.

        let item1 = NSSplitViewItem(sidebarWithViewController: battlelistViewController)

        let item2 = NSSplitViewItem(viewController: chatViewController)

        let item3 = NSSplitViewItem(contentListWithViewController: userListViewController)

        [item1, item2, item3].forEach(viewController.addSplitViewItem)

        // Return the split view controller.

        return viewController
    }

    // MARK: - Actions

    /// An action to be triggered when a user wishes to leave a battleroom.
    ///
    /// After the battleroom is destroyed, the notification that the user wishes to leave the battle is sent to the server.
    @objc private func leaveBattle() {
        destroyBattleroom()
        battleController?.leaveBattle()
        leaveBattleButton.isHidden = true
        // Deselect the battle so the player may re-select it.
        battlelistViewController.tableView.deselectAll(nil)
    }
}
