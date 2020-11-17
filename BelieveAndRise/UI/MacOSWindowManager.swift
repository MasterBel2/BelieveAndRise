//
//  MacOSWindowManager.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 22/9/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa
import UberserverClientCore

#warning("Window manager accesses the UI and should be made thread-safe by use of executeOnMain on its non-private functions.")
/// The MacOS implementation of `WindowManager`.
final class MacOSWindowManager: WindowManager {
    /// The window displaying information about current and past downloads.
    private var downloadsWindow: NSWindow?
    private var replaysWindow: NSWindow?
    weak var system: System!

    /// The controller for storing and retrieving interface-related defaults.
    private let defaultsController = InterfaceDefaultsController()

    // MARK: - WindowManager

    func newClientWindowManager(clientController: ClientController) -> ClientWindowManager {
        let manager = MacOSClientWindowManager(defaultsController: defaultsController)
        manager.clientController = clientController
        return manager
    }

    func presentReplays(_ controller: ReplayController, springProcessController: SpringProcessController) {
        if let replaysWindow = replaysWindow {
            replaysWindow.orderFront(self)
            return
        }
        let viewController = ListViewController()
        viewController.selectionHandler = ReplayListSelectionHandler(
            replayList: controller.replays,
            springProcessController: springProcessController
        )
        viewController.itemViewProvider = ReplayListItemViewProvider(replayList: controller.replays)
        viewController.addSection(controller.replays)
        let replaysWindow = NSWindow(contentViewController: viewController)

        replaysWindow.makeKeyAndOrderFront(self)

        self.replaysWindow = replaysWindow
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
