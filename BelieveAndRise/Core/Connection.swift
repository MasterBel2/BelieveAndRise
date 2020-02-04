//
//  Connection.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 8/9/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/**
 An object that at an abstract level represents a connection between a user and the server.

 A connection handles the top-level data and windows associated with a client-server connection, as well as handling the outputting of
 commands back to the server.

 Updates received from the server are processed by instances of the SCServerCommand protocol. The Connection object simply manages
 the interactions between its various components as needed.
 */
final class Connection: ServerSelectionViewControllerDelegate {

    // MARK: - Dependencies

    /// Provides platform-specific windows.
    let windowManager: WindowManager
    ///
    let resourceManager: ResourceManager
    /// The user's preferences controller.
    let preferencesController: PreferencesController

    // MARK: - Components

    /// Processes incoming commands and updates the model and UI appropriately.
    let commandHandler = CommandHandler()
    /// Processes chat-related information directed back towards the server
    let chatController: ChatController
	let battleController: BattleController
    /// The server.
    private(set) var server: TASServer!
    private(set) var userAuthenticationController: UserAuthenticationController?

    // MARK: - Data

    private var serverMetaData: ServerMetaData?

    let channelList = List<Channel>(title: "All Channels", sortKey: .title)
    let userList = List<User>(title: "All Users", sortKey: .rank)
    let battleList = List<Battle>(title: "All Battles", sortKey: .playerCount)

    // MARK: - Lifecycle


    init(windowManager: WindowManager, resourceManager: ResourceManager, preferencesController: PreferencesController, address: ServerAddress? = nil) {
        self.windowManager = windowManager
        self.resourceManager = resourceManager
        self.preferencesController = preferencesController

        battleController = BattleController(battleList: battleList)
        chatController = ChatController(windowManager: windowManager)

        // Configure the command handler
        commandHandler.connection = self
        commandHandler.setProtocol(.unknown)

        // Initialise server
        if let address = address {
            initialiseServer(address)
        }
    }

    // MARK: - Interacting with the server connection

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
		
        chatController.server = server
        battleController.server = server
		
		self.server = server
	}

    // MARK: - Window

    /// 
    func createAndShowWindow() {
        windowManager.presentInitialWindow()
        configureInterface()
        if server == nil {
            windowManager.presentServerSelection(delegate: self)
        }
    }

    private func configureInterface() {
        windowManager.setBattleController(battleController)
        windowManager.setChatController(chatController)
        windowManager.displayBattlelist(battleList)
        windowManager.displayServerUserlist(userList)
    }

    // MARK: - Presenting information

    /// Presents a login control to the user.
    func presentLogin() {
        let userAuthenticationController = UserAuthenticationController(server: server, windowManager: windowManager, preferencesController: preferencesController)
        windowManager.presentLogin(controller: userAuthenticationController)
        self.userAuthenticationController = userAuthenticationController
    }

    /// Handles an error from the server.
    func receivedError(_ error: ServerError) {
        switch error {
		default:
            print(error)
            fatalError()
			#warning("FIXME")
        }
    }

    // MARK: - ServerSelectionViewControllerDelegate

    func serverSelectionViewController(_ serverSelectionViewController: ServerSelectionViewController, didSelectServerAt serverAddress: ServerAddress) {
        // Connect to the selected server.
        initialiseServer(serverAddress)
		
		start()
    }

    // MARK: - Helpers

    /// Returns ID of a player, if they are online.
    func id(forPlayerNamed username: String) -> Int? {
        return userList.items.first { (_, user) in
            return user.profile.fullUsername == username
        }?.key
    }

    /// The unique integer ID of channels, keyed by their name.
	private var channelIDs: [String : Int] = [:]
    /// Retrieves the unique integer ID for a channel.
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
        /// The IP address of th server.
        let ip: String
        /// The server port.
        let port: Int
        /// The server's "Message of the Day".
        ///
        /// The MotD is receieved dynamically after the user logs in.
        var motd: String
    }
}
