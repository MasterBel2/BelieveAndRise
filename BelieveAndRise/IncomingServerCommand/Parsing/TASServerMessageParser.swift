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
            let command = recognisedCommand.init(server: server, arguments: Array(components.dropFirst()), dataSource: self, delegate: self) else {
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
            "ACCEPTED" : DummyCommand.self,
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
        mainWindow?.contentViewController = viewController
        self.userAuthenticationController = userAuthenticationController
    }

    // Login

    private var loginAttempts: [String] = []

    func failLogin(reason: String) {
        print("Login failed: \(reason)")
    }

    func completeLogin() {
        userAuthenticationController?.loginDidSucceed()
    }

    // Battleroom

    func createBattleroom(_ battleRoom: Battleroom, identifiedBy id: Int) {}

    func destroyBattleroomWithID(_ id: Int) {}

    func createChannel(named name: String) {}

    func destroyChannel(named name: String) {}

    func createBattle(_ battle: Battle, identifiedBy id: Int) {
        battlelist.addBattle(battle, with: id)
        let battlelistViewController = battelistViewController ?? ListViewController()
        self.battelistViewController = battlelistViewController

        battlelistViewController.setTableSections(
            [
                ListTableSection(
                    title: "All Battles",
                    entries: [
                        ListTableEntry(primaryTitle: battle.title, secondaryTitle: "\(battle.playerCount)/\(battle.maxPlayers) + \(battle.spectatorCount)")
                    ]
                )
            ]
        )
    }

    func createBattleWithID(identifiedBy id: Int) {}

    func notifyUser(of message: CustomStringConvertible, isError: Bool) {}


}

protocol ActionTriggeringSheet {
    //    func indicateActionResult(_ actionResult: Result)
}
