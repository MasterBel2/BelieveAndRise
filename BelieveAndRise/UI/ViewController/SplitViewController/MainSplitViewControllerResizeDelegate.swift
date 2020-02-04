//
//  MainSplitViewControllerResizeDelegate.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 3/2/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa

/// An implementation of the `SplitViewControllerResizeDelegate` associated with MainWindowController's split view controller.
final class MainSplitViewControllerResizeDelegate: SplitViewControllerResizeDelegate {
    /// The view controller displaying the battlelist, embedded in a split view item.
    private let battlelistViewController: NSViewController
    /// The view controller displaying the playerlist, embedded in a split view item.
    private let playerlistViewController: NSViewController

    /// The controller for storing and retrieving interface-related defaults.
    private let interfaceDefaultsController: InterfaceDefaultsController

    // MARK: - Lifecycle

    init(battlelistViewController: NSViewController, playerlistViewController: NSViewController, interfaceDefaultsController: InterfaceDefaultsController) {
        self.battlelistViewController = battlelistViewController
        self.playerlistViewController = playerlistViewController

        self.interfaceDefaultsController = interfaceDefaultsController
    }

    // MARK: - SplitViewControllerResizeDelegate

    func splitViewController(_ splitViewController: NSSplitViewController, viewWasResizedFor viewController: NSViewController) {
        // Update the default width for the modified column.
        if viewController === battlelistViewController {
            interfaceDefaultsController.defaultBattlelistSidebarWidth = battlelistViewController.view.frame.width
        } else if viewController === playerlistViewController {
            interfaceDefaultsController.defaultPlayerListSidebarWidth = playerlistViewController.view.frame.width
        }
    }
}
