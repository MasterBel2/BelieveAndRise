//
//  ServerSelectionDialogSheet.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 18/6/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa
import ServerAddress
import UberserverClientCore

/// A sheet providing an interface for selecting a lobbyserver to connect to.
final class ServerSelectionDialogSheet: DialogSheet, NSComboBoxDataSource, NSComboBoxDelegate {

	/// Allows a user to select a server or enter a custom address.
    @IBOutlet var comboSelectionBox: NSComboBox!
    
    /// A block to be called with the selected server address.
    var completionHandler: ((ServerAddress) -> Void)!

	/// A list of server options to pre-fill for the user to select from.
    private var options: [String] = ["Official Server", "BA Server", "BAR Server"]

    override func viewDidLoad() {
        super.viewDidLoad()

        doneButton.title = "Connect"

        comboSelectionBox.usesDataSource = true
        comboSelectionBox.dataSource = self

        controlsToDisable.append(comboSelectionBox)

        operation = { [weak self] _ -> Bool  in
            guard let self = self else {
                return false
            }
            guard let validServerAddress = self.validServerAddress(from: self.comboSelectionBox.stringValue) else {
                self.operationDidFailWithError("\(self.comboSelectionBox.stringValue) is not a valid address.")
                return false
            }

            self.completionHandler(validServerAddress)
            return true
        }
    }

	/// Validates a server address, returning nil if it is invalid.
    private func validServerAddress(from string: String) -> ServerAddress? {
        switch string.lowercased() {
        case "Official Server".lowercased():
            return ServerAddress(location: "lobby.springrts.com", port: 8200)
        case "BA Server".lowercased():
            return ServerAddress(location: "springfightclub.com", port: 8200)
        case "BAR Server".lowercased():
            return ServerAddress(location: "road-flag.bnr.la", port: 8200)
        default:
            let storedValue = string.components(separatedBy: ":")
            guard storedValue.count == 2, let port = Int(storedValue[1]) else { return nil }
            return ServerAddress(location: storedValue[0], port: port)
        }
    }

    // MARK: - NSComboBoxDataSource

    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return options[index]
    }

    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return options.count
    }
}
