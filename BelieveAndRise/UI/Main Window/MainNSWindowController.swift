//
//  MainNSWindowController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 5/9/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

final class MainNSWindowController: NSWindowController, MainWindowController {

    // MARK: - Dependencies

    weak var connection: Connection?
    private weak var chatController: ChatController?
    private weak var battleController: BattleController?

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
        if let battleroomViewController = battleroomViewController,
            let battleroomSplitViewItem = splitViewController.splitViewItem(for: battleroomViewController) {
            self.battleroomViewController = nil
            splitViewController.removeSplitViewItem(battleroomSplitViewItem)
            splitViewController.insertSplitViewItem(NSSplitViewItem(viewController: chatViewController), at: 1)
        }
        leaveBattleButton.isHidden = true
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
        return "MainNSWindowController"
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        let splitViewController = newSplitViewController()

        window?.contentViewController?.addChild(splitViewController)
        window?.contentView?.addSubview(splitViewController.view)
        splitViewController.view.frame = window?.contentView?.frame ?? .zero
        splitViewController.view.autoresizingMask = [.width, .height]
        splitViewController.view.viewDidMoveToWindow()

        chatViewController.setViewBackgroundColor(.controlBackgroundColor)

        self.splitViewController = splitViewController

        leaveBattleButton.isHidden = true
        battlelistViewController.footer = leaveBattleButton
    }

    let leaveBattleButton = NSButton(title: "Leave Battle", target: self, action: #selector(leaveBattle))

    private func newSplitViewController() -> NSSplitViewController {
        let viewController = NSSplitViewController()

        let item1 = NSSplitViewItem(sidebarWithViewController: battlelistViewController)
        item1.automaticMaximumThickness = 150

        let item2 = NSSplitViewItem(viewController: chatViewController)

        let item3 = NSSplitViewItem(contentListWithViewController: userListViewController)
        item3.automaticMaximumThickness = 150

        [item1, item2, item3].forEach(viewController.addSplitViewItem)

        return viewController
    }

    // MARK: - Actions

    @objc private func leaveBattle() {
        battleController?.leaveBattle()
        destroyBattleroom()
        leaveBattleButton.isHidden = true
    }
}
