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

	var connectionController: ConnectionController!
    var resourceManager: ResourceManager!
    var downloadController: DownloadController!
    var mainWindowController: NSWindowController?
    let windowManager: WindowManager = MacOSWindowManager()

    var downloadsWindow: NSWindow?

    // MARK: - Menu Items

    @IBOutlet weak var recentConnectionsMenuItem: NSMenu!

    /// Displays downloads to the user.
	@IBAction func showDownloads(_ sender: NSMenuItem) {
		windowManager.presentDownloads(downloadController)
	}

    /// Opens a new connection.
    @IBAction func newServerConnection(_ sender: Any) {
        connectionController.createNewConnection()
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
        let system = MacOS()
        downloadController = DownloadController(system: system)

        let resourceManager = ResourceManager(
			downloadController: downloadController,
			windowManager: windowManager
		)
        resourceManager.loadLocalResources()

        let connectionController = ConnectionController(windowManager: windowManager, resourceManager: resourceManager, preferencesController: PreferencesController())
        connectionController.createNewConnection()

        self.connectionController = connectionController
        self.resourceManager = resourceManager
	}
}
