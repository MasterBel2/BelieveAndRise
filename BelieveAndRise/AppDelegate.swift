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

	/// Handles the connection to the server.
	///
	/// `applicationDidFinishLaunching()` must be called to initialise this object
    var server: TASServer!
    var window: NSWindow?
	var parser: TASServerDelegate!

	var clientController: ClientController!
    var resourceManager: ResourceManager!
    var downloadController: DownloadController!
    var mainWindowController: NSWindowController?
    let windowManager: WindowManager = MacOSWindowManager()

    var downloadsWindow: NSWindow?

    // MARK: - Menu Items

    @IBOutlet weak var recentClientsMenuItem: NSMenu!

    /// Displays downloads to the user.
	@IBAction func showDownloads(_ sender: NSMenuItem) {
		windowManager.presentDownloads(downloadController)
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

        let system = MacOS()
        downloadController = DownloadController(system: system)

        let resourceManager = ResourceManager(
			downloadController: downloadController,
			windowManager: windowManager
		)
        resourceManager.loadLocalResources()

        let clientController = ClientController(windowManager: windowManager, resourceManager: resourceManager, preferencesController: PreferencesController.default)
        clientController.createNewClient()

        self.clientController = clientController
        self.resourceManager = resourceManager
	}
}
