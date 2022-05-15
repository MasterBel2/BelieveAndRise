//
//  MacOSClientWindowManager.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 22/9/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa
import UberserverClientCore
import ServerAddress

#warning("ClientWindowManager accesses the UI and should be made thread-safe by use of `executeOnMain` on its non-private functions.")
/// A MacOS-specific implementation of `ClientWindowManager`.
final class MacOSClientWindowManager: NSResponder, ClientWindowManager {

    // MARK: - Windows

    private var mainWindowController = MainWindowController()
    /// The window displaying information about the currently logged in account.
    private var accountWindow: NSWindow?

    private var chatSidebar: ListViewController
    private var chatWindow: NSWindow
    private var chatViewController: ChatViewController
    
    private var serverSelectionViewController: NSViewController?

    // MARK: - Dependencies

    weak var client: Client?
    weak var clientController: ClientController?
    private let defaultsController: InterfaceDefaultsController

    // MARK: - Sheets

    private var sheets: [SheetType : NSWindow] = [:]
    private var sheetSizes: [SheetType : CGSize] = [
        .serverSelection : CGSize(width: 290, height: 150)
    ]
	
	private var openBattleWindow: NSWindow?
	
	@IBAction func openBattle(_ sender: Any) {
		let vc = BattleroomSetupViewController()
        vc.completionHandler = { [weak self] in
            executeOnMainSync {
                self?.openBattleWindow?.close()
                self?.openBattleWindow = nil
            }
        }
		vc.client = client
		let window = NSWindow(contentViewController: vc)
		window.title = "Battleroom Setup Test"
		window.makeKeyAndOrderFront(self)
		self.openBattleWindow = window
        mainWindowController.hostBattleButton.isEnabled = false
	}

    @IBAction func chatWindow(_ sender: Any) {
        chatWindow.makeKeyAndOrderFront(self)
    }

    @IBAction func accountWindow(_ sender: Any) {
        guard let client = client else {
            return
        }
        presentAccountWindow(client.accountInfoController)
    }

    // MARK: - Lifecycle

    init(defaultsController: InterfaceDefaultsController) {
        chatSidebar = ListViewController()
        let chatViewController = ChatViewController()
        let splitViewController = ResizeTrackingSplitViewController()
        chatSidebar.view.setFrameSize(CGSize(width: defaultsController.defaultChatSidebarWidth, height: chatViewController.view.frame.height))

        splitViewController.resizeDelegate = ChatWindowSplitViewControllerResizeDelegate(
            chatSidebar: chatSidebar,
            chatViewController: chatViewController,
            interfaceDefaultsController: defaultsController
        )

        splitViewController.addItems(forViewControllers: [chatSidebar, chatViewController])

        let chatWindow = NSPanel(contentViewController: splitViewController)
        chatWindow.title = "Chat"
        chatWindow.isFloatingPanel = true
        self.chatWindow = chatWindow
        chatWindow.setFrameAutosaveName("com.believeAndRise.chat")
        self.chatViewController = chatViewController

        self.defaultsController = defaultsController
        super.init()
        nextResponder = mainWindowController.nextResponder
        mainWindowController.nextResponder = self
        chatWindow.nextResponder = self
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

        chatSidebar.removeAllSections()
        chatSidebar.addSection(client.channelList)
        chatSidebar.addSection(client.privateMessageList)
        chatSidebar.addSection(client.forwardedMessageList)
        chatSidebar.selectionHandler = ChatSidebarSelectionHandler(channelList: client.channelList, privateMessageList: client.privateMessageList, forwardedMessageList: client.forwardedMessageList, chatViewController: chatViewController)
        chatSidebar.itemViewProvider = ChatSidebarListItemViewProvider(channelList: client.channelList, privateMessageList: client.privateMessageList, forwardedMessageList: client.forwardedMessageList)
        chatViewController.chatController = client.chatController
    }

    func resetServerWindows() {
        destroyBattleroom()
        accountWindow?.close()
        accountWindow = nil
        dismissLogin()
        dismissServerSelection()
    }

    // MARK: - Sheets
    
    func selectServer(completionHandler: @escaping (ServerAddress) -> Void) {
        let serverSelectionViewController = ServerSelectionDialogSheet()
        serverSelectionViewController.didCancelOperation = { [weak self] in
            guard let self = self,
                let client = self.client else {
                return
            }
            self.mainWindowController.close()
            self.clientController?.destroyClient(client)
        }
        serverSelectionViewController.completionHandler = completionHandler
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

    func joinedChannel(_ channel: Channel) {
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
            self.selectServer(completionHandler: client.initialiseServer(_:))
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
