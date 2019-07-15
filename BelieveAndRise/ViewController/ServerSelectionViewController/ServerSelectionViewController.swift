//
//  ServerSelectionViewController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 12/7/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

protocol ServerSelectionViewControllerDelegate: AnyObject {
    func serverSelectionViewController(_ serverSelectionViewController: ServerSelectionViewController, didSelectServerAt serverAddress: ServerAddress)
}

final class ServerSelectionViewController: NSViewController, NSComboBoxDataSource, NSComboBoxDelegate {

    // MARK: - Outlets

    /// A text field displaying the view's title.
    @IBOutlet weak var titleField: NSTextField!
    @IBOutlet weak var comboBox: NSComboBox!
    @IBOutlet weak var doneButton: NSButton!

    // MARK: - Dependencies

    /// The server selection view controller's delegate.
    weak var delegate: ServerSelectionViewControllerDelegate?

    // MARK: - Customisation

    private var options: [String] = ["Official Server"]

    override var title: String? {
        didSet {
            titleField.stringValue = title ?? ""
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        comboBox.usesDataSource = true
        comboBox.dataSource = self
        comboBox.reloadData()
        doneButton.becomeFirstResponder()
    }

    /// Attempts to submit the specified server address.
    @IBAction func completeEditing(_ sender: Any) {
        guard let validServerAddress = validServerAddress(from: comboBox.stringValue) else { return }
        disableUI()
        delegate?.serverSelectionViewController(self, didSelectServerAt: validServerAddress)
    }

    // MARK: - NSComboBoxDataSource

    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return options[index]
    }

    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return options.count
    }

    // MARK: - NSComboBoxDelegate

    // MARK: - Private helpers

    /// Disables the interface and presents a spinner to indicate work in progress.
    private func disableUI() {
        // TODO: this could be applicable to more view controllers; consider adding this as an internal extension of NSViewController
        #warning("Stubbed function")
    }

    /// Attempts to construct a server address from the input string.
    private func validServerAddress(from string: String) -> ServerAddress? {
        #warning("Function returns dummy value")
        return ServerAddress(location: "lobby.springrts.com", port: 8200)
    }
}

/// Specifies the connection details for a lobby server.
struct ServerAddress {
    /// The domain/IP of a server
    let location: String
    /// The port on which the connection should be made
    let port: Int
}
