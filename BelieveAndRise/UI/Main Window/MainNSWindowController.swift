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

    var connection: Connection?

    // MARK: - Data

    /// The primary list acts as a navigation
    private(set) var primaryListViewController = ListViewController()
    private var chatViewController = ChatViewController()
    private var secondaryListViewController: ListViewController {
        return chatViewController.logViewController
    }
    private(set) var supplementaryListViewController = ListViewController()

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
    }

    private func newSplitViewController() -> NSSplitViewController {
        let viewController = NSSplitViewController()

        viewController.addSplitViewItem(NSSplitViewItem(sidebarWithViewController: primaryListViewController))
        viewController.addSplitViewItem(NSSplitViewItem(viewController: chatViewController))
        viewController.addSplitViewItem(NSSplitViewItem(contentListWithViewController: supplementaryListViewController))

        return viewController
    }
}
