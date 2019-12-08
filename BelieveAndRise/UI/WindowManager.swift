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
	func makeKeyAndOrderFront(_ window: Window)
	func initialWindow() -> Window
	func presentPrompt(to window: Window)
	
    func presentInitialWindow()

	func mainWindowController() -> MainWindowController

    func presentServerSelection(toWindowFor windowController: WindowController?, delegate: ServerSelectionViewControllerDelegate?)
	
	func presentDownloads(_ controller: DownloadController)
}

enum WindowType: Hashable {
    case main
    case hud
    case sheet
}

#warning("Window manager accesses the UI and should be made thread-safe by use of executeOnMain() on its non-private functions.")
final class MacOSWindowManager: WindowManager {
    init() {
        #warning("These values are supposed to be stored so that they persist between launches.")
        cachedWindowSizes = [
            .main : CGSize(width: 480, height: 300),
            .hud : CGSize(width: 180, height: 300),
            .sheet : CGSize(width: 290, height: 150)
        ]
    }
	
	// MARK: - Windows
	
	private var downloadsWindow: NSWindow?

    // MARK: - Customisation

    private var cachedWindowSizes: [WindowType : CGSize]

    // MARK: - Convenience getters

    private var mainWindow: NSWindow? {
        return NSApplication.shared.mainWindow
    }

    private var keyWindow: NSWindow? {
        return NSApplication.shared.keyWindow
    }
	
	// MARK: - Constructors

    private func newSplitViewController() -> NSViewController {
        let viewController = NSSplitViewController()

        let list = ListViewController()
        let chat = ListViewController()
        let players = ListViewController()

        viewController.addSplitViewItem(NSSplitViewItem(sidebarWithViewController: list))
        viewController.addSplitViewItem(NSSplitViewItem(contentListWithViewController: chat))
        viewController.addSplitViewItem(NSSplitViewItem(viewController: players))

        return viewController
    }

    /// Creates a new instance of a window with the standard arrangement of view controllers.
    /// "Main" terminology is not to be confused with `NSApplication.mainWindow`.
    private func newMainWindow() -> NSWindow {
        let window = NSWindow(contentViewController: newSplitViewController())
        window.setContentSize(cachedWindowSizes[WindowType.main]!)
        return window
    }

    private func newHUDWindow(contentViewController: NSViewController) -> NSWindow {
        let window = NSWindow(contentViewController: contentViewController)
        window.setContentSize(cachedWindowSizes[WindowType.hud]!)
        window.styleMask = NSWindow.StyleMask(rawValue: window.styleMask.rawValue & NSWindow.StyleMask.hudWindow.rawValue)
        return window
    }

    private func presentSheet(with contentViewController: NSViewController, to window: NSWindow) {
        let sheet = NSWindow(contentViewController: contentViewController)
        sheet.setContentSize(cachedWindowSizes[WindowType.sheet]!)
        sheet.styleMask = NSWindow.StyleMask(rawValue: sheet.styleMask.rawValue & ~NSWindow.StyleMask.resizable.rawValue)
        window.beginSheet(sheet, completionHandler: nil)
    }

    // MARK: - Public API

    // MARK: - WindowManager

    /// Presents a new instance of the main window. (Currently an alias for `presentServerSelection()`)
    ///
    /// This method assumes that it is being called because no window exists already. It will not
    /// check for (or remove) any windows that have already been presented.
    func presentInitialWindow() {
        let initialWindowController = self.mainWindowController()
        presentServerSelection(toWindowFor: initialWindowController, delegate: nil)
    }

    /// Presents a server selection sheet. If there is no main window, a new window is created for
    /// the sheet to be presented to.
    func presentServerSelection(toWindowFor windowController: WindowController?, delegate: ServerSelectionViewControllerDelegate?) {
        let serverSelectionViewController = ServerSelectionViewController()
        serverSelectionViewController.delegate = delegate
        let mainWindow = windowController?._window as? NSWindow ?? self.mainWindow ?? newMainWindow()
        presentSheet(with: serverSelectionViewController, to: mainWindow)
    }
	
	// MARK: - Platform UI wrappers
	
	func initialWindow() -> Window {
		return newMainWindow()
	}

    func mainWindowController() -> MainWindowController {
        return MainNSWindowController()
    }
	
	func presentPrompt(to window: Window) {
		presentSheet(with: ServerSelectionViewController(), to: window as! NSWindow)
	}
	
	func makeKeyAndOrderFront(_ window: Window) {
		(window as! NSWindow).makeKeyAndOrderFront(self)
	}
	
	func presentDownloads(_ downloadController: DownloadController) {
		if let downloadsWindow = downloadsWindow {
			downloadsWindow.orderFront(self)
		} else {
			let downloadsViewController = ListViewController()
			downloadsViewController.shouldDisplaySectionHeaders = false
			downloadsViewController.itemViewProvider = DownloadItemProvider(
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
}

protocol Window {
	func setContentSize(_: CGSize)

    /// Dismisses all blocking prompts from the window.
    func dismissPrompts()
}

protocol MainWindow: Window {
    func setPrimaryListContent<T: Sortable>(_ list: List<T>)
}

extension NSWindow: Window {
    func dismissPrompts() {
        for sheet in sheets {
            endSheet(sheet)
        }
    }
}

