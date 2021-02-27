//
//  AppDelegate.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 24/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa
import UberserverClientCore

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Properties

    var window: NSWindow?

	var clientController: ClientController!
    var downloadController: DownloadController!
    var replayController: ReplayController!
    var mainWindowController: NSWindowController?
    var system: System!
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

    @objc func addSomething() {
        let newView = NSTextField()
        newView.stringValue = "Hello!"
        stackView?.animateInsertion(ofArrangedSubviews: [newView], at: [0], completionHandler: nil)
    }
    @objc func removeSomething() {
        stackView?.animateRemoval(ofViewsAt: [0], completionHandler: nil)
    }
    var stackView: NSStackView?

    func testStackViews() {
        let stackView = NSStackView(views: [
            NSButton(title: "Add!", target: self, action: #selector(addSomething)),
            NSButton(title: "Remove!", target: self, action: #selector(removeSomething))
        ])
        self.stackView = stackView
        let window = NSWindow()
        window.title = "NSStackView test"
        window.contentView = stackView
        window.makeKeyAndOrderFront(self)
        self.window = window
    }

	func applicationDidFinishLaunching(_ aNotification: Notification) {
        runNormally()
//        testForms()
    }

    func testForms() {
        let viewController = FormViewController()
        viewController.pages = [TestFormPageViewController(), TestFormPageViewController()]
        let window = NSWindow(contentViewController: viewController)
        window.title = "Form Test"
        window.makeKeyAndOrderFront(self)
        self.window = window
    }
    
    func runNormally() {
        Logger.log("Logger is online", tag: .General)

        system = MacOS(windowManager: MacOSWindowManager())

        downloadController = DownloadController(system: system)
        replayController = ReplayController(system: system)
        springProcessController = SpringProcessController(system: system, replayController: replayController)

        ResourceManager.make(downloadController: downloadController, windowManager: system.windowManager, archiveLoader: UnitsyncArchiveLoader())
        ResourceManager.default.loadLocalResources()

        let clientController = ClientController(
            windowManager: system.windowManager,
            preferencesController: PreferencesController.default,
            springProcessController: springProcessController
        )
        clientController.createNewClient()

        self.clientController = clientController
    }
}

