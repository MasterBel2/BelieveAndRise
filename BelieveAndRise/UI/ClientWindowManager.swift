//
//  ClientWindowManager.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 9/2/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa

/// A set of functions providing a platform-agnostic interface for platform-specific windows associated with a single client.
protocol ClientWindowManager {
    func configure(for client: Client)

    func presentInitialWindow()
    /// Displays an window with information about the logged in user's account
    func presentAccountWindow(_ controller: AccountInfoController)

    /// Presents the server selection interface, with a delegate.
    func presentServerSelection(delegate: ServerSelectionDelegate)
    /// Dismisses the server selection interface.
    func dismissServerSelection()
    /// Present a login interface.
    func presentLogin(controller: UserAuthenticationController)
    /// Dismisses the login interface.
    func dismissLogin()

    func resetServerWindows()

    func displayBattlelist(_ battleList: List<Battle>)
    func displayServerUserlist(_ userList: List<User>)
    func displayBattleroom(_ battleroom: Battleroom)

    func destroyBattleroom()

    func setChatController(_ chatController: ChatController)
    func setBattleController(_ battleController: BattleController)
}

#warning("ClientWindowManager accesses the UI and should be made thread-safe by use of `executeOnMain` on its non-private functions.")
/// A MacOS-specific implementation of `ClientWindowManager`.
final class MacOSClientWindowManager: NSResponder, ClientWindowManager {

    // MARK: - Windows

    private var mainWindowController = MainWindowController()
    /// The window displaying information about the currently logged in account.
    private var accountWindow: NSWindow?

    // MARK: - Dependencies

    weak var client: Client?
    weak var clientController: ClientController?
    private let defaultsController: InterfaceDefaultsController

    // MARK: - Sheets

    private var sheets: [SheetType : NSWindow] = [:]
    private var sheetSizes: [SheetType : CGSize] = [
        .serverSelection : CGSize(width: 290, height: 150)
    ]

    @IBAction func accountWindow(_ sender: Any) {
        guard let client = client else {
            return
        }
        presentAccountWindow(client.accountInfoController)
    }

    // MARK: - Lifecycle

    init(defaultsController: InterfaceDefaultsController) {
        self.defaultsController = defaultsController
        super.init()
        nextResponder = mainWindowController.nextResponder
        mainWindowController.nextResponder = self
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - WindowManager

    /// Presents a new instance of the main window. (Currently an alias for `presentServerSelection()`)
    ///
    /// This method assumes that it is being called because no window exists already. It will not
    /// check for (or remove) any windows that have already been presented.
    func presentInitialWindow() {
        mainWindowController.defaultsController = defaultsController
        mainWindowController.window?.makeKeyAndOrderFront(self)
    }

    func configure(for client: Client) {
        self.client = client
        setBattleController(client.battleController)
        setChatController(client.chatController)
        displayBattlelist(client.battleList)
        displayServerUserlist(client.userList)
    }

    func resetServerWindows() {
        destroyBattleroom()
        accountWindow?.close()
        accountWindow = nil
        dismissLogin()
        dismissServerSelection()
    }

    // MARK: - Sheets

    var serverSelectionViewController: NSViewController?
    /// Presents a server selection sheet. If there is no main window, a new window is created for
    /// the sheet to be presented to.
    func presentServerSelection(delegate: ServerSelectionDelegate) {
        let serverSelectionViewController = ServerSelectionDialogSheet()
        serverSelectionViewController.delegate = delegate
        serverSelectionViewController.didCancelOperation = { [weak self] in
            guard let self = self,
                let client = self.client else {
                return
            }
            self.mainWindowController.close()
            self.clientController?.destroyClient(client)
        }
        mainWindowController.window?.contentViewController?.presentAsSheet(serverSelectionViewController)
        self.serverSelectionViewController = serverSelectionViewController
    }

    /// Dismisses the sheet associated with the server selection controller.
    func dismissServerSelection() {
        serverSelectionViewController?.dismiss(self)
    }

    var loginViewController: NSViewController?
    /// Configures the login sheet with the controller and presents it to the users.
    func presentLogin(controller: UserAuthenticationController) {
        dismissServerSelection()
        let viewController = userAuthenticationViewController(controller: controller)
        mainWindowController.window?.contentViewController?.presentAsSheet(viewController)
        self.loginViewController = viewController
    }

    /// Dismisses the sheet associated with the user authentication controller.
    func dismissLogin() {
        loginViewController?.dismiss(self)
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
        userAuthenticationViewController.didCancelOperation = { [weak self] in
            guard let self = self,
                let client = self.client else {
                return
            }
            self.presentServerSelection(delegate: client)
        }
        userAuthenticationViewController.delegate = controller
        _userAuthenticationViewController = userAuthenticationViewController
        return userAuthenticationViewController
    }

    func presentAccountWindow(_ controller: AccountInfoController) {
        if let accountWindow = accountWindow {
            accountWindow.orderFront(self)
            return
        }
        let accountViewController = AccountViewController()
        accountViewController.delegate = controller
        accountViewController.accountInfoController = controller
        let accountWindow = NSPanel(contentViewController: accountViewController)
        accountWindow.title = "Account – \(controller.user?.profile.fullUsername ?? "Unknown user")"
        accountWindow.isFloatingPanel = true
        accountWindow.setFrameAutosaveName("com.believeAndRise.accountInfo")
        accountWindow.titlebarAppearsTransparent = true
        accountWindow.makeKeyAndOrderFront(self)
        self.accountWindow = accountWindow
    }

    // MARK: - Nested types

    private enum SheetType: Hashable {
        case login
        case serverSelection
    }
}
