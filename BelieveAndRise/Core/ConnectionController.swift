//
//  ConnectionController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 8/9/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/**
 The Connection Controller facilitates creation of connections to the server
 */
final class ConnectionController {
    private(set) var connections: [Connection] = []
    /// Provides platform-specific windows.
    private let windowManager: WindowManager
    private let resourceManager: ResourceManager
    /// The user's preferences controller.
    let preferencesController: PreferencesController

    init(windowManager: WindowManager, resourceManager: ResourceManager, preferencesController: PreferencesController) {
        self.windowManager = windowManager
        self.resourceManager = resourceManager
        self.preferencesController = preferencesController
    }

    /// On update, inserts the most recent connection
    private(set) var recentConnections: [URL] = [] {
        didSet {
            if let first = recentConnections.first {
                recentConnections.removeAll(where: { $0 == first })
            }
            if recentConnections.count > 5 {
                recentConnections = recentConnections.dropLast()
            }
        }
    }

    /// Initiates a connection to the given address.
    func connect(to address: ServerAddress) {
        let connection = Connection(windowManager: windowManager, resourceManager: resourceManager, preferencesController: preferencesController, address: address)
        connection.start()
        connection.createAndShowWindow()
        self.connections.append(connection)
    }

    /// Creates a new connection without a predefined server
    func createNewConnection() {
        let connection = Connection(windowManager: windowManager, resourceManager: resourceManager, preferencesController: preferencesController)
        connection.createAndShowWindow()
        self.connections.append(connection)
    }
}
