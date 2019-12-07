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
    private(set) var primaryListViewController = ListViewController()
    private var chatViewController = ChatViewController()
    private var secondaryListViewController: ListViewController {
        return chatViewController.logViewController
    }
    private(set) var supplementaryListViewController = ListViewController()

    private(set) var battleroomViewController: NSViewController?

    private var splitViewController: NSSplitViewController!

    // MARK: - MainWindowController

    var primaryListDisplay: ListDisplay {
        return primaryListViewController
    }

    var secondaryListDisplay: ListDisplay {
        return secondaryListViewController
    }

    var supplementaryListDisplay: ListDisplay {
        return supplementaryListViewController
    }

    /**
     Displays a battleroom and configures it with the information that should be already populated
     */
    func displayBattleroom(_ battleroom: Battleroom) {

        // Set up view

        // Update data

        if let battleroomViewController = self.battleroomViewController as? BattleroomViewController {
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
    }

    private func newSplitViewController() -> NSSplitViewController {
        let viewController = NSSplitViewController()

        let item1 = NSSplitViewItem(sidebarWithViewController: primaryListViewController)
        item1.automaticMaximumThickness = 150

        let item2 = NSSplitViewItem(viewController: chatViewController)

        let item3 = NSSplitViewItem(contentListWithViewController: supplementaryListViewController)
        item3.automaticMaximumThickness = 150

        [item1, item2, item3].forEach(viewController.addSplitViewItem)

        return viewController
    }
}
