//
//  WindowManager.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 7/8/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

/// A set of functions providing a platform-agnostic interface for platform-specific window creation.
protocol WindowManager {
	/// Immediately displays current and past downloads to the user.
	func presentDownloads(_ controller: DownloadController)

    /// Creates a new manager for connection-specific windows.
    func newConnectionWindowManager(connectionController: ConnectionController) -> ConnectionWindowManager
}

#warning("Window manager accesses the UI and should be made thread-safe by use of executeOnMain on its non-private functions.")
/// The MacOS implementation of `WindowManager`.
final class MacOSWindowManager: WindowManager {
    /// The window displaying information about current and past downloads.
    private var downloadsWindow: NSWindow?

    /// The controller for storing and retrieving interface-related defaults.
    private let defaultsController = InterfaceDefaultsController()

    // MARK: - WindowManager

    func newConnectionWindowManager(connectionController: ConnectionController) -> ConnectionWindowManager {
        let manager = MacOSConnectionWindowManager(defaultsController: defaultsController)
        manager.connectionController = connectionController
        return manager
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
}
