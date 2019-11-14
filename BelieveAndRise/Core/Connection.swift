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

    // MARK: - Dependencies

    /// Provides platform-specific windows.
    private let windowManager: WindowManager
    ///
    let resourceManager: ResourceManager

    // MARK: - Components

    /// Processes incoming commands and updates the model and UI appropriately.
    let commandHandler = CommandHandler()
    /// Processes chat-related information directed back towards the server
    private(set) var chatController: ChatController!
	private(set) var battleController: BattleController!
    /// Controls the main window associated with the server conenction.
    private(set) var windowController: MainWindowController!
    /// The server.
    private(set) var server: TASServer!
    private(set) var userAuthenticationController: UserAuthenticationController?

    // MARK: - Data

    private var serverMetaData: ServerMetaData?

    let channelList = List<Channel>(title: "All Channels", sortKey: .title)
    let userList = List<User>(title: "All Users", sortKey: .rank)
    let battleList = List<Battle>(title: "All Battles", sortKey: .playerCount)

    // MARK: - Lifecycle


    init(windowManager: WindowManager, resourceManager: ResourceManager, address: ServerAddress? = nil) {
        self.windowManager = windowManager
        self.resourceManager = resourceManager

        // Configure the command handler
        commandHandler.connection = self
        commandHandler.setProtocol(.unknown)

        // Initialise server
        if let address = address {
            initialiseServer(address)
        }
    }

    // MARK: - Controlling the server connection

    func start() {
        server.connect()
    }
	
	func redirect(to address: ServerAddress) {
		server.disconnect()
		commandHandler.setProtocol(.unknown)
		#warning("Pass information to the user!")
		initialiseServer(address)
		start()
	}
	
	func initialiseServer(_ address: ServerAddress) {
		let server = TASServer(address: address)
		server.delegate = commandHandler
		
		chatController = ChatController(server: server, windowManager: windowManager)
		battleController = BattleController(battleList: battleList, server: server)
		
		windowController.primaryListDisplay.selectionHandler = DefaultBattleListSelectionHandler(battlelist: battleList, battleController: battleController)

		windowController.setChatController(chatController)
		
		self.server = server
	}

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
        windowController.primaryListDisplay.itemViewProvider = BattlelistItemViewProvider(list: battleList)
        windowController.supplementaryListDisplay.addSection(userList)
        windowController.supplementaryListDisplay.itemViewProvider = DefaultPlayerListItemViewProvider(list: userList)
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
		default:
			fatalError()
			#warning("FIXME")
        }
    }

    // MARK: - ServerSelectionViewControllerDelegate

    ///
    func serverSelectionViewController(_ serverSelectionViewController: ServerSelectionViewController, didSelectServerAt serverAddress: ServerAddress) {
        initialiseServer(serverAddress)
		
		start()
    }

    // MARK: - Helpers

    func id(forPlayerNamed username: String) -> Int? {
        return userList.items.first { (_, user) in
            return user.profile.username == username
        }?.key
    }
	
	private var channelIDs: [String : Int] = [:]
	func id(forChannelnamed channelName: String) -> Int {
		if let id = channelIDs[channelName] {
			return id
		} else {
			let id = channelIDs.count
			channelIDs[channelName] = id
			return id
		}
	}

    // MARK: - Helper types

    /// Contains information about a lobby server.
    struct ServerMetaData {
        let ip: String
        let port: Int
        var motd: String
    }
}
