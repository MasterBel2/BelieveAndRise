//
//  AppDelegate.swift
//  BelieveAndRiseSwiftUI
//
//  Created by MasterBel2 on 21/9/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa
import SwiftUI
import UberserverClientCore
import ServerAddress

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var clientController: ClientController!


    func applicationDidFinishLaunching(_ aNotification: Notification) {

        let system = MacOS(windowManager: SwiftUIWindowManager())
        let downloadController = DownloadController(system: system)
        let resourceManager = ResourceManager(downloadController: downloadController, windowManager: system.windowManager)
        let replayController = ReplayController(system: system)
        let springProcessController = SpringProcessController(system: system, replayController: replayController)
        clientController = ClientController(windowManager: system.windowManager, resourceManager: resourceManager, preferencesController: PreferencesController.default, springProcessController: springProcessController)

        clientController.connect(to: ServerAddress(location: "springfightclub.com", port: 8200))
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

class SwiftUIWindowManager: WindowManager {
    func presentDownloads(_ controller: DownloadController) {
        //
    }

    func presentReplays(_ controller: ReplayController, springProcessController: SpringProcessController) {
        //
    }

    func newClientWindowManager(clientController: ClientController) -> ClientWindowManager {
        return SwiftUIClientWindowManager(clientController: clientController)
    }

}

class SwiftUIClientWindowManager: ClientWindowManager {
    let clientController: ClientController
    let viewModel = ViewModel()
    weak var client: Client!

    public init(clientController: ClientController) {
        self.clientController = clientController
    }

    var window: NSWindow!

    func configure(for client: Client) {
        self.client = client
        viewModel.client = client
    }

    func presentInitialWindow() {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(viewModel: viewModel)

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func presentAccountWindow(_ controller: AccountInfoController) {
        //
    }

    func presentServerSelection(delegate: ServerSelectionDelegate) {
        //
    }

    func dismissServerSelection() {
        //
    }

    func presentLogin(controller: UserAuthenticationController) {
        //
    }

    func dismissLogin() {
        //
    }

    func resetServerWindows() {
        //
    }

    func displayBattleroom(_ battleroom: Battleroom) {
        //
    }

    func destroyBattleroom() {
        //
    }
}
