//
//  ServerCommandParser.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 30/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

final class TASServerMessageParser: TASServerDelegate, IncomingServerCommandDataSource, IncomingServerCommandDelegate {

    // MARK: - Properties

    let battlelist = Battlelist()

    // MARK: - Interaction

    var userAuthenticationController: UserAuthenticationController?

    private weak var battelistViewController: ListViewController?

    // MARK: - Something

    private var recognisedCommands: [String : IncomingServerCommand.Type] = [
        "TASSERVER" : TASServerCommand.self
    ]

    // MARK: - TASServerDelegate

    func server(_ server: TASServer, didReceive serverCommand: String) {
        // debug
        print(serverCommand)

        let components = serverCommand.components(separatedBy: " ")
        guard let _command = components.first?.uppercased(),
            let recognisedCommand = recognisedCommands[_command],
            let command = recognisedCommand.init(server: server, payload: components.dropFirst().joined(separator: " "), dataSource: self, delegate: self) else {
                return
        }
        command.execute()
    }
 
    // MARK: - IncomingServerCommandDataSource

    var mainWindow: NSWindow? {
        return NSApplication.shared.mainWindow
    }

    var keyWindow: NSWindow? {
        return NSApplication.shared.keyWindow
    }

    // MARK: - IncomingServerCommandDelegate

    // Server

    func connectedToServer(_ server: TASServer) {
         recognisedCommands = [
            "ACCEPTED" : LoginAcceptedCommand.self,
            "DENIED" : DummyCommand.self,
            "LOGININFOEND" : DummyCommand.self,

            "BATTLEOPENED" : BattleOpenedCommand.self,
            "MOTD" : MOTDCommand.self
        ]

        presentLogin(for: server)
    }

    private func presentLogin(for server: TASServer) {
        let userAuthenticationController = UserAuthenticationController(server: server)
        let viewController = userAuthenticationController.viewController
        keyWindow?.contentViewController = viewController
        self.userAuthenticationController = userAuthenticationController
    }

    // Login

    private var loginAttempts: [String] = []

    func failLogin(reason: String) {
        print("Login failed: \(reason)")
    }

    func completeLogin() {
        userAuthenticationController?.loginDidSucceed()

        executeOnMain(target: self) { parser in
            let battlelistViewController = ListViewController()
			if let mainWindow = parser.mainWindow {
				mainWindow.contentViewController = battelistViewController
				mainWindow.sheets.forEach { mainWindow.endSheet($0)}
			}
			
            // Maintain the same window size if possible
            parser.something()

            parser.battelistViewController = battlelistViewController
        }
    }

    // Battleroom

    func createBattleroom(_ battleRoom: Battleroom, identifiedBy id: Int) {}

    func destroyBattleroomWithID(_ id: Int) {}

    func createChannel(named name: String) {}

    func destroyChannel(named name: String) {}

    func createBattle(_ battle: Battle, identifiedBy id: Int) {
        battlelist.addBattle(battle, with: id)
        something()
    }
    private func something() {
        let rows = battlelist.battles.map {
            return ListTableEntry(primaryTitle: $0.value.founder, secondaryTitle: "\($0.value.playerCount) players")
        }
        let x = ListTableSection(
            title: "Battles",
            entries: rows
        )

        executeOnMain(target: self) { parser in
            parser.battelistViewController?.setTableSections([x])
        }
    }

    func createBattleWithID(identifiedBy id: Int) {}

    func notifyUser(of message: CustomStringConvertible, isError: Bool) {}
}

protocol ActionTriggeringSheet {
    //    func indicateActionResult(_ actionResult: Result)
}
