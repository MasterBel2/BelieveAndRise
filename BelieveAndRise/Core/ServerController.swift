//
//  ServerController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 26/8/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

protocol LobbyClientDelegate {
	
}

/// A threadsafe wrapper protocol for platform-specific UI implementation
protocol WindowController: AnyObject {
    func showWindow(_ sender: Any?)
    /// The window controller's window, abstracted behind a platform-agnostic protocol.
    var _window: Window? { get }
}

extension NSWindowController: WindowController {
    var _window: Window? {
        return window
    }
}

protocol ListDisplay: AnyObject {
    func addSection(_ list: ListProtocol)
    func removeSection(_ list: ListProtocol)
	var itemViewProvider: ItemViewProvider { get set }
	var selectionHandler: ListSelectionHandler? { get set }
}

protocol MainWindowController: WindowController {
    var primaryListDisplay: ListDisplay { get }
    var secondaryListDisplay: ListDisplay { get }
    var supplementaryListDisplay: ListDisplay { get }

    func displayBattleroom(_ battleroom: Battleroom)
	
	func setChatController(_ chatController: ChatController)
}

protocol MainWindowDelegate: AnyObject {
	
}
