//
//  IncomingServerCommandDataSource.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 30/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

/// Provides data
protocol IncomingServerCommandDataSource: AnyObject {
    /// The application's main window
    var mainWindow: NSWindow? { get }
    /// The window that currently receives keyboard events
    var keyWindow: NSWindow? { get }
    /// The current user authentication controller. Creates a new one if there is not already one present.
    var userAuthenticationController: UserAuthenticationController? { get }
}

protocol IncomingServerCommandDelegate: AnyObject {
    /// Indicates that a connection to a server was made.
    func connectedToServer(_ server: TASServer)

    /// 
    func failLogin(reason: String)

    /// Sets up the application after logging in.
    func completeLogin()

    /// Creates a battleroom with the given ID and pushes it to the update stack.
    func createBattleroom(_ battleRoom: Battleroom, identifiedBy id: Int)
    
    /// Destroys the battleroom with the given ID, removing it from the update stack.
    func destroyBattleroomWithID(_ id: Int)
    
    /// Creates a channel with the given name and pushes it to the update stack.
    func createChannel(named name: String)
    
    /// Destroys the battleroom with the given name, removing it from the update stack.
    func destroyChannel(named name: String)
    
    /// Creates a battle with the given ID, adding it to the battlelist and
    /// pushing it to the update stack.
    func createBattle(_ battle: Battle, identifiedBy id: Int)
    
    /// Destroys the battle with the given ID, removing it from the battlelist
    /// and update stack.
    func createBattleWithID(identifiedBy id: Int)
    
    /// Notifies the user of the given message, indicating whether it is an error or not.
    ///
    /// Errors should provide enough information that the user may fully report what went wrong.
    func notifyUser(of message: CustomStringConvertible, isError: Bool)
}
