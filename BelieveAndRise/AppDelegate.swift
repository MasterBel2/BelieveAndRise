//
//  AppDelegate.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 24/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Properties

    var window: NSWindow?
	var parser: TASServerDelegate!

	var clientController: ClientController!
    var resourceManager: ResourceManager!
    var downloadController: DownloadController!
    var replayController: ReplayController!
    var mainWindowController: NSWindowController?
    let system = MacOS()
    var springProcessController: SpringProcessController!

    var downloadsWindow: NSWindow?

    // MARK: - Menu Items

    @IBOutlet weak var recentClientsMenuItem: NSMenu!

    /// Displays downloads to the user.
	@IBAction func showDownloads(_ sender: NSMenuItem) {
        system.windowManager.presentDownloads(downloadController)
	}
    @IBAction func showReplays(_ sender: NSMenuItem) {
        try? replayController.loadReplays()
        system.windowManager.presentReplays(replayController, springProcessController: springProcessController)
    }

    /// Opens a new client.
    @IBAction func newClient(_ sender: Any) {
        clientController.createNewClient()
    }
    @IBAction func printResponders(_ sender: Any) {
        var responder = NSApplication.shared.keyWindow?.firstResponder
        while let actualResponder = responder {
            print(actualResponder)
            responder = actualResponder.nextResponder
        }
    }

	// MARK: - NSApplicationDelegate

	func applicationDidFinishLaunching(_ aNotification: Notification) {
        Logger.log("Logger is online", tag: .General)

        downloadController = DownloadController(system: system)
        replayController = ReplayController(system: system)
        springProcessController = SpringProcessController(system: system, replayController: replayController)

        let resourceManager = ResourceManager(
			downloadController: downloadController,
            windowManager: system.windowManager
		)
        resourceManager.loadLocalResources()

        let clientController = ClientController(
            windowManager: system.windowManager,
            resourceManager: resourceManager,
            preferencesController: PreferencesController.default,
            springProcessController: springProcessController
        )
        clientController.createNewClient()

        self.clientController = clientController
        self.resourceManager = resourceManager
	}
}

