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

	var window: NSWindow?
	/// Handles the connection to the server.
	///
	/// `applicationDidFinishLaunching()` must be called to initialise this object
    var server: TASServer!
	var parser: TASServerDelegate!

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		createInitialWindow()
	}
	
	// MARK: - Private Helpers
	
	private func createInitialWindow() {
        let viewController = ServerSelectionViewController()
        viewController.delegate = self


		let window = NSWindow(contentViewController: viewController)
		// TODO: - Store window sizes
		window.setContentSize(CGSize(width: 480, height: 300))
		window.makeKeyAndOrderFront(self)

		self.window = window
	}
}

extension AppDelegate: ServerSelectionViewControllerDelegate {
    func serverSelectionViewController(_ serverSelectionViewController: ServerSelectionViewController, didSelectServerAt serverAddress: ServerAddress) {
        let server = TASServer(address: serverAddress)
        let parser = TASServerMessageParser()
        server.delegate = parser
        server.connect()

        self.server = server
        self.parser = parser
    }
}


struct IncompleteAuthenticateUserRequest {
    let username: String?
    let password: String?
    let email: String?

    static var empty: IncompleteAuthenticateUserRequest {
        return IncompleteAuthenticateUserRequest(username: nil, password: nil, email: nil)
    }
}
