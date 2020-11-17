//
//  MacOSClientWindowManager.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 22/9/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa
import UberserverClientCore

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
        mainWindowController.setBattleController(client.battleController)
        mainWindowController.setChatController(client.chatController)
        mainWindowController.displayBattlelist(client.battleList)
        mainWindowController.displayServerUserlist(client.userList)
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

    func displayBattleroom(_ battleroom: Battleroom) {
        mainWindowController.displayBattleroom(battleroom)
    }

    func destroyBattleroom() {
        mainWindowController.destroyBattleroomViewController()
    }

    // MARK: - Platform UI wrappers

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
