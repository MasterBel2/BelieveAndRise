//
//  ConnectionWindowManager.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 9/2/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa

/// A set of functions providing a platform-agnostic interface for platform-specific windows associated with a single connection.
protocol ConnectionWindowManager {
    func presentInitialWindow()

    /// Presents the server selection interface, with a delegate.
    func presentServerSelection(delegate: ServerSelectionViewControllerDelegate)
    /// Dismisses the server selection interface.
    func dismissServerSelection()
    /// Present a login interface.
    func presentLogin(controller: UserAuthenticationController)
    /// Dismisses the login interface.
    func dismissLogin()

    func displayBattlelist(_ battleList: List<Battle>)
    func displayServerUserlist(_ userList: List<User>)
    func displayBattleroom(_ battleroom: Battleroom)

    func destroyBattleroom()

    func setChatController(_ chatController: ChatController)
    func setBattleController(_ battleController: BattleController)
}

#warning("ConnectionWindowManager accesses the UI and should be made thread-safe by use of `executeOnMain` on its non-private functions.")
/// A MacOS-specific implementation of `ConnectionWindowManager`.
final class MacOSConnectionWindowManager: ConnectionWindowManager {

    // MARK: - Windows

    private var mainWindowController = MainWindowController()

    // MARK: - Dependencies

    private let defaultsController: InterfaceDefaultsController

    // MARK: - Sheets

    private var sheets: [SheetType : NSWindow] = [:]
    private var sheetSizes: [SheetType : CGSize] = [
        .serverSelection : CGSize(width: 290, height: 150)
    ]

    // MARK: - Lifecycle

    init(defaultsController: InterfaceDefaultsController) {
        self.defaultsController = defaultsController
    }

    // MARK: - WindowManager

    /// Presents a new instance of the main window. (Currently an alias for `presentServerSelection()`)
    ///
    /// This method assumes that it is being called because no window exists already. It will not
    /// check for (or remove) any windows that have already been presented.
    func presentInitialWindow() {
        let mainWindowController = MainWindowController()
        mainWindowController.defaultsController = defaultsController
        mainWindowController.window?.makeKeyAndOrderFront(self)
        self.mainWindowController = mainWindowController
    }

    // MARK: - Sheets

    /// Presents a server selection sheet. If there is no main window, a new window is created for
    /// the sheet to be presented to.
    func presentServerSelection(delegate: ServerSelectionViewControllerDelegate) {
        let serverSelectionViewController = ServerSelectionViewController()
        serverSelectionViewController.delegate = delegate
        presentSheet(with: serverSelectionViewController, ofType: .serverSelection)
    }

    /// Dismisses the sheet associated with the server selection controller.
    func dismissServerSelection() {
        dismissSheet(.serverSelection)
    }

    /// Configures the login sheet with the controller and presents it to the users.
    func presentLogin(controller: UserAuthenticationController) {
        dismissServerSelection()
        let viewController = userAuthenticationViewController(controller: controller)
        presentSheet(with: viewController, ofType: .login)
    }

    /// Dismisses the sheet associated with the user authentication controller.
    func dismissLogin() {
        dismissSheet(.login)
    }

    // MARK: - Content

    func displayBattlelist(_ battleList: List<Battle>) {
        mainWindowController.displayBattlelist(battleList)
    }

    func displayServerUserlist(_ userList: List<User>) {
        mainWindowController.displayServerUserlist(userList)
    }

    func displayBattleroom(_ battleroom: Battleroom) {
        mainWindowController.displayBattleroom(battleroom)
    }

    func destroyBattleroom() {
        mainWindowController.destroyBattleroomViewController()
    }

    func setChatController(_ chatController: ChatController) {
        mainWindowController.setChatController(chatController)
    }

    func setBattleController(_ battleController: BattleController) {
        mainWindowController.setBattleController(battleController)
    }

    // MARK: - Platform UI wrappers

    private func presentSheet(with contentViewController: NSViewController, ofType sheetType: SheetType) {
        guard let mainWindow = mainWindowController.window else {
            return
        }
        let sheet = NSWindow(contentViewController: contentViewController)
        if let sheetSize = sheetSizes[sheetType] {
            sheet.setContentSize(sheetSize)
        }
        sheet.styleMask.remove(.resizable)
        mainWindow.beginSheet(sheet, completionHandler: nil)
        sheets[sheetType] = sheet
    }

    private func dismissSheet(_ type: SheetType) {
        if let sheetWindow = sheets[type] {
            mainWindowController.window?.endSheet(sheetWindow)
            sheets.removeValue(forKey: type)
        }
    }

    private var _userAuthenticationViewController: UserAuthenticationViewController?
    private func userAuthenticationViewController(controller: UserAuthenticationController) -> NSViewController {
        let userAuthenticationViewController = UserAuthenticationViewController()
        userAuthenticationViewController.delegate = controller
        controller.display = userAuthenticationViewController
        _userAuthenticationViewController = userAuthenticationViewController
        return userAuthenticationViewController
    }

    // MARK: - Nested types

    private enum SheetType: Hashable {
        case login
        case serverSelection
    }
}
