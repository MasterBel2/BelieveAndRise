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
		presentServerWindow()
	}
	
	// MARK: - Private Helpers
	
	private func presentServerWindow() {


	}

    private func createInitialWindow() {
        let viewController = NSSplitViewController()

        let window = NSWindow(contentViewController: viewController)
        // TODO: - Store window sizes
        window.setContentSize(CGSize(width: 480, height: 300))

        let battlelist = ListViewController()
        let battleChat = ListViewController()
        let battlePlayers = ListViewController()

        viewController.addSplitViewItem(NSSplitViewItem(sidebarWithViewController: battlelist))
        viewController.addSplitViewItem(NSSplitViewItem(contentListWithViewController: battleChat))
        viewController.addSplitViewItem(NSSplitViewItem(viewController: battlePlayers))

        window.makeKeyAndOrderFront(self)
		
		// TODO: - Store and load window sizes
		window.setContentSize(CGSize(width: 480, height: 300))
		window.orderFront(self)
		window.makeMain()

        self.window = window
		
		// Server selection

        let other = ServerSelectionViewController()
        other.delegate = self

        let something = NSWindow(contentViewController: other)

        self.window?.beginCriticalSheet(something, completionHandler: nil)
		something.makeKey()
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

func executeOnMain<T: AnyObject>(target: T, block: (T) -> Void) {
    if Thread.isMainThread {
        block(target)
    } else {
        DispatchQueue.main.sync {
            block(target)
        }
    }
}
