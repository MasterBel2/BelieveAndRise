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
    var resourceManager = ResourceManager()
    var mainWindowController: NSWindowController?
    let windowManager: WindowManager = MacOSWindowManager()

    // MARK: - NSApplicationDelegate

	func applicationDidFinishLaunching(_ aNotification: Notification) {
        resourceManager.loadLocalResources()
        let connectionController = ConnectionController(windowManager: windowManager, resourceManager: resourceManager)
        connectionController.createNewConnection()
        self.connectionController = connectionController
	}
}
