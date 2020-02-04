//
//  WindowManager.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 7/8/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

/// A set of functions allowing platform-agnostic window creation.
protocol WindowManager {
    func presentInitialWindow()

    func presentServerSelection(delegate: ServerSelectionViewControllerDelegate)
    func dismissServerSelection()
    func presentLogin(controller: UserAuthenticationController)
    func dismissLogin()
	
	/// Immediately displays current and past downloads to the user.
	func presentDownloads(_ controller: DownloadController)

    func displayBattlelist(_ battleList: List<Battle>)
    func displayServerUserlist(_ userList: List<User>)
    func displayBattleroom(_ battleroom: Battleroom)

    func destroyBattleroom()

    func setChatController(_ chatController: ChatController)
    func setBattleController(_ battleController: BattleController)
}



#warning("Window manager accesses the UI and should be made thread-safe by use of executeOnMain() on its non-private functions.")
final class MacOSWindowManager: WindowManager {
	
	// MARK: - Windows

    private var mainWindowController = MainWindowController()
	private var downloadsWindow: NSWindow?

    /// The controller for storing and retrieving interface-related defaults.
    private let defaultsController = InterfaceDefaultsController()

    // MARK: - Sheets

    private var sheets: [SheetType : NSWindow] = [:]
    private var sheetSizes: [SheetType : CGSize] = [
        .serverSelection : CGSize(width: 290, height: 150)
    ]

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
        mainWindowController.destroyBattleroom()
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
	
	func presentDownloads(_ downloadController: DownloadController) {
		if let downloadsWindow = downloadsWindow {
			downloadsWindow.orderFront(self)
		} else {
			let downloadsViewController = ListViewController()
			downloadsViewController.shouldDisplaySectionHeaders = false
			downloadsViewController.itemViewProvider = DownloadItemViewProvider(
				downloadList: downloadController.downloadList,
				downloadItemViewDelegate: downloadController
			)
			
			downloadController.display = downloadsViewController
			
			let downloadsWindow = NSPanel(contentViewController: downloadsViewController)
			downloadsWindow.title = "Downloads"
			downloadsWindow.isFloatingPanel = true
			downloadsWindow.setFrameAutosaveName("com.believeAndRise.downloads")
			downloadsWindow.titlebarAppearsTransparent = true
			downloadsWindow.makeKeyAndOrderFront(self)
			self.downloadsWindow = downloadsWindow
		}
	}

    // MARK: - Nested types

    private enum SheetType: Hashable {
        case login
        case serverSelection
    }
}
