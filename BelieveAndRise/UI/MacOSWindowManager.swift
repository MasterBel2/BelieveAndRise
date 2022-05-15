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
final class MacOSWindowManager: ReceivesClientControllerUpdates {
    /// The window displaying information about current and past downloads.
    private var downloadsWindow: NSWindow?
    private var replaysWindow: NSWindow?

    private var clientWindowManagers: [MacOSClientWindowManager] = []

    /// The controller for storing and retrieving interface-related defaults.
    private let defaultsController = InterfaceDefaultsController()

    let resourceManager: ResourceManager

    init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
    }

    // MARK: - Presenting

    func presentReplays(_ controller: ReplayController) {
        if let replaysWindow = replaysWindow {
            replaysWindow.orderFront(self)
            return
        }
        let viewController = ListViewController()
        viewController.selectionHandler = ReplayListSelectionHandler(
            replayList: controller.replays,
            resourceManager: resourceManager
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

    // MARK: - Client Controller Updates

    func clientController(_ clientController: ClientController, didCreate client: Client) {
        let windowManager = MacOSClientWindowManager(defaultsController: defaultsController)
        client.addObject(windowManager)
        windowManager.client = client
        windowManager.clientController = clientController

        windowManager.prepare()
        if client.connection == nil {
            windowManager.selectServer(completionHandler: client.connect(to:))
        }

        clientWindowManagers.append(windowManager)
    }
}
