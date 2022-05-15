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
final class MacOSClientWindowManager: NSResponder, ReceivesClientUpdates, ReceivesConnectionUpdates, RecievesPreAgreementSessionUpdates, ReceivesAuthenticatedClientUpdates {

    // MARK: - Windows

    private var mainWindowController = MainWindowController()
    /// The window displaying information about the currently logged in account.
    private var accountWindow: NSWindow?

    private var chatSidebar: ListViewController
    private var chatWindow: NSWindow
    private var chatViewController: ChatViewController
    
    private var serverSelectionViewController: NSViewController?
    private var loginViewController: NSViewController?

    // MARK: - Dependencies

    weak var client: Client? {
        didSet {
            mainWindowController.client = client
        }
    }
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
        guard let client = client,
              let connection = client.connection,
              case let .authenticated(session) = connection.session else {
            return
        }
        presentAccountWindow(session)
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

        mainWindowController.defaultsController = defaultsController
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Client Updates

    func client(_ client: Client, willConnectTo address: ServerAddress) {
        client.addObject(self)
    }

    func client(_ client: Client, successfullyEstablishedConnection connection: Connection) {
        connection._connection.sync(block: { $0.addObject(self) })

        executeOnMainSync {
            self.serverSelectionViewController?.dismiss(self)
        }

        guard case let .unauthenticated(unauthenticatedSession) = connection.session else {
            executeOnMainSync {
                self.selectServer(completionHandler: client.connect(to:))
            }
            return
        }

        executeOnMainSync { [self] in
            let viewController = userAuthenticationViewController(controller: unauthenticatedSession)
            mainWindowController.window?.contentViewController?.presentAsSheet(viewController)
            self.loginViewController = viewController
        }
    }

    func client(_ client: Client, willRedirectFrom oldServerAddress: ServerAddress, to newServerAddress: ServerAddress) {

    }

    func client(_ client: Client, didSuccessfullyRedirectTo newConnection: Connection) {

    }

    func clientDisconnectedFromServer(_ client: Client) {
        executeOnMainSync { [self] in
            agreementAlert?.close()
            agreementAlert = nil
            mainWindowController.destroyBattleroomViewController()
            accountWindow?.close()
            accountWindow = nil
            mainWindowController.window?.contentViewController?.presentedViewControllers?.forEach({ $0.dismiss(self) })

            selectServer(completionHandler: client.connect(to:))
        }
    }

    // MARK: - Connection Updates

    func connection(_ connection: ThreadUnsafeConnection, willConnectTo newAddress: ServerAddress) {}

    func serverDidDisconnect(_ server: Connection) {}

    func server(_ server: Connection, willUseCommandProtocolWithFeatureAvailability availability: ProtocolFeatureAvailability) {}

    func connection(_ connection: ThreadUnsafeConnection, didBecomeAuthenticated authenticatedClient: AuthenticatedSession) {
        executeOnMainSync { [self] in
            self.agreementAlert = nil

            authenticatedClient.addObject(self)

            mainWindowController.configure(for: authenticatedClient)

            chatSidebar.removeAllSections()
            chatSidebar.addSection(authenticatedClient.channelList)
            chatSidebar.addSection(authenticatedClient.privateMessageList)
            chatSidebar.addSection(authenticatedClient.forwardedMessageList)
            chatSidebar.selectionHandler = ChatSidebarSelectionHandler(
                channelList: authenticatedClient.channelList,
                privateMessageList: authenticatedClient.privateMessageList,
                forwardedMessageList: authenticatedClient.forwardedMessageList,
                chatViewController: chatViewController
            )
            chatSidebar.itemViewProvider = ChatSidebarListItemViewProvider(
                channelList: authenticatedClient.channelList,
                privateMessageList: authenticatedClient.privateMessageList,
                forwardedMessageList: authenticatedClient.forwardedMessageList
            )
            chatViewController.authenticatedClient = authenticatedClient
        }
    }

    func connection(_ connection: ThreadUnsafeConnection, didBecomePreAgreement preAgreementSession: PreAgreementSession) {
        preAgreementSession.addObject(self)
    }

    func connection(_ connection: ThreadUnsafeConnection, didBecomeUnauthenticated unauthenticatedSession: UnauthenticatedSession) {
        executeOnMainSync {
            self._userAuthenticationViewController?.unauthenticatedSession = unauthenticatedSession
            self.mainWindowController.deconfigure()
        }
    }

    // MARK: - Pre-Agreement Updates

    private var agreementAlert: NSWindow?

    func preAgreementSession(_ session: PreAgreementSession, didReceiveAgreement agreement: String) {
        executeOnMainSync {
            let dialog = AgreementDialogViewController()
            dialog.agreement = agreement
            dialog.operation = { dialog in
                guard let dialog = dialog as? AgreementDialogViewController else {
                    dialog.didCancelOperation?(dialog)
                    return false
                }
                session.acceptAgreement(verificationCode: dialog.confirmationCodeField.stringValue)
                return true
            }
            dialog.didCancelOperation = { [weak self] _ in
                self?.client?.disconnect()
            }

            let window = NSWindow(contentViewController: dialog)
            self.agreementAlert = window

            window.makeKeyAndOrderFront(self)
        }
    }


    // MARK: - Authenticated Client Updates

    func authenticatedClient(_ authenticatedClient: AuthenticatedSession, didJoin battleroom: Battleroom) {
        executeOnMainSync {
            self.mainWindowController.displayBattleroom(battleroom)
        }
    }

    func authenticatedClientDidLeaveBattleroom(_ authenticatedClient: AuthenticatedSession) {
        executeOnMainSync {
            self.mainWindowController.destroyBattleroomViewController()
        }
    }

    // MARK: - WindowManager

    /// Presents the main window.
    func prepare() {
        mainWindowController.window?.makeKeyAndOrderFront(self)
    }

    // MARK: - Sheets
    
    func selectServer(completionHandler: @escaping (ServerAddress) -> Void) {
        let serverSelectionViewController = ServerSelectionDialogSheet()
        serverSelectionViewController.didCancelOperation = { [weak self] dialog in
            dialog.dismiss(self)
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

    // MARK: - Platform UI wrappers

    private var _userAuthenticationViewController: UserAuthenticationViewController?
    private func userAuthenticationViewController(controller: UnauthenticatedSession) -> NSViewController {
        let userAuthenticationViewController = UserAuthenticationViewController()
        userAuthenticationViewController.didCancelOperation = { [weak self] dialog in
            dialog.dismiss(self)
            guard let self = self,
                let client = self.client else {
                return
            }
            client.disconnect()
            self.selectServer(completionHandler: client.connect(to:))
        }
        userAuthenticationViewController.unauthenticatedSession = controller
        _userAuthenticationViewController = userAuthenticationViewController
        return userAuthenticationViewController
    }

    func presentAccountWindow(_ controller: AuthenticatedSession) {
        if let accountWindow = accountWindow {
            accountWindow.orderFront(self)
            return
        }
        let accountViewController = AccountViewController()
        accountViewController.authenticatedSession = controller
        let accountWindow = NSPanel(contentViewController: accountViewController)
        accountWindow.title = "Account – \(controller.myUser?.profile.fullUsername ?? "Unknown user")"
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
