//
//  Connection.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 8/9/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation
import Cocoa

/**
 An object that at an abstract level represents a connection between a user and the server.

 A connection handles the top-level data and windows associated with a client-server connection, as well as handling the outputting of
 commands back to the server.
 */
final class Connection: LobbyClientDelegate, ServerSelectionViewControllerDelegate {

    // MARK: - Helper types

    /// Contains information about a lobby server.
    struct ServerMetaData {
        let ip: String
        let port: Int
        var motd: String
    }

    // MARK: - Components

    /// Controls the main window associated with the server conenction.
    private(set) var windowController: MainWindowController!
    /// The server
    private(set) var server: TASServer!
    private(set) var userAuthenticationController: UserAuthenticationController?

    // MARK: - Data

    private var serverMetaData: ServerMetaData?

    let channelList = List<Channel>(title: "All Channels", sortKey: .id)
    let userList = List<User>(title: "All Users", sortKey: .rank)
    let battleList = List<Battle>(title: "All Battles", sortKey: .playerCount)

    // MARK: - Components

    private(set) var client: LobbyClient?

    // MARK: - Controlling the server connection

    func start() {
        server.connect()
    }

    // MARK: - Configuration



    // MARK: - Window

    func createAndShowWindow() {
        let windowController = windowManager.mainWindowController()
        configureWindow(for: windowController)
        if server == nil {
            windowManager.presentServerSelection(toWindowFor: windowController, delegate: self)
        }
        windowController.showWindow(self)
        self.windowController = windowController
    }

    private func configureWindow(for windowController: MainWindowController) {
        windowController.primaryListDisplay.addSection(battleList)
        windowController.primaryListDisplay.setItemViewProvider(BattlelistItemViewProvider(list: battleList))
        windowController.supplementaryListDisplay.addSection(userList)
        windowController.supplementaryListDisplay.setItemViewProvider(DefaultPlayerListItemViewProvider(list: userList))
    }

    // MARK: - Presenting information

    func presentLogin() {
        let userAuthenticationController = UserAuthenticationController(server: server)
        let viewController = userAuthenticationController.viewController
        windowController._window?.dismissPrompts()
        (windowController._window as! NSWindow).beginSheet(NSWindow(contentViewController: viewController), completionHandler: nil)
        self.userAuthenticationController = userAuthenticationController
    }

    func receivedError(_ error: ServerError) {
        switch error {
        case .joinFailed(let (channel, reason)):
            print("Join #\(channel) failed: \(reason)")
        }
    }

    // MARK: - Dependencies

    /// Provides platform-specific windows.
    private let windowManager: WindowManager

    // MARK: - Lifecycle


    init(windowManager: WindowManager, address: ServerAddress? = nil) {
        self.windowManager = windowManager

        // Initialise command handler
        let commandHandler = CommandHandler()
        commandHandler.connection = self
        self.commandHandler = commandHandler

        // Initialise server
        if let address = address {
            let server = TASServer(address: address)
            server.delegate = commandHandler
            self.server = server
        }
    }

    // MARK: - ServerSelectionViewControllerDelegate

    /// Processes incoming commands and updates the model and UI appropriately.
    private(set) var commandHandler: CommandHandler?

    ///
    func serverSelectionViewController(_ serverSelectionViewController: ServerSelectionViewController, didSelectServerAt serverAddress: ServerAddress) {
        let server = TASServer(address: serverAddress)
        server.delegate = commandHandler
        server.connect()

        self.server = server
    }

    // MARK: - Helpers

    func id(forPlayerNamed username: String) -> Int? {
        return userList.items.first { (_, user) in
            return user.profile.username == username
        }?.key
    }
}
