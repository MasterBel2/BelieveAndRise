//
//  BattleroomSetupViewController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 28/7/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa
import UberserverClientCore

class BattleroomSetupViewController: NSViewController, NSTextFieldDelegate {
    
    // MARK: - Associated Objects
	
	weak var client: Client!
	
    private var archiveLoader: DescribesArchivesOnDisk {
        return client.resourceManager.archiveLoader
    }
	
	// MARK: - Interface
	
    @IBOutlet var titleField: NSTextField!
	@IBOutlet weak var gameSelectionBox: NSPopUpButton!
	@IBOutlet var engineSelectionBox: NSPopUpButton!
    @IBOutlet var descriptionField: NSTextField!
    @IBOutlet var showRestrictionsMenu: NSButton!
    @IBOutlet var restrictionsLabel: NSTextField!
	
	@IBOutlet var openBattleButton: NSButton!
	@IBOutlet var spinner: NSProgressIndicator!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.font = .boldSystemFont(ofSize: 22.0)
        titleField.stringValue = "Configure Battleroom"
        descriptionField.delegate = self
		
		// If the archive loader is refreshed, it will corrupt the available options.
		// So cache the options that are available when setting up the UI.
		engines = archiveLoader.engines
		engines.forEach({ engineSelectionBox.addItem(withTitle: $0.version) })
		
		games = archiveLoader.modArchives
		games.forEach({ gameSelectionBox.addItem(withTitle: $0.name )})
		
		setUIEnabled(true)
		updateOpenBattleButtonState()
    }
    
    var completionHandler: (() -> Void)?
	
	// MARK: - UI State
    
	private var uiIsEnabled = true
    
    // MARK: - Cached data
	
	private var engines: [Engine] = []
	private var selectedEngine: Engine?
	
	private var games: [ModArchive] = []
	private var selectedGame: ModArchive?
    
    // MARK: - Updating the UI
	
	private func updateOpenBattleButtonState() {
		openBattleButton.isEnabled = uiIsEnabled
			&& selectedEngine != nil
			&& selectedGame != nil
			&& descriptionField.stringValue != ""
	}
	
	func setUIEnabled(_ isEnabled: Bool) {
		uiIsEnabled = isEnabled
		spinner.isHidden = isEnabled
		engineSelectionBox.isEnabled = isEnabled
		gameSelectionBox.isEnabled = isEnabled
		descriptionField.isEnabled = isEnabled
		openBattleButton.isEnabled = isEnabled
	}
	
    // MARK: - UI Events
    
    func controlTextDidChange(_: Notification) {
        updateOpenBattleButtonState()
    }
    
    @IBAction func selectGame(_ sender: NSPopUpButton) {
        if sender.indexOfSelectedItem == 0 {
            selectedGame = nil
        } else {
            selectedGame = games[sender.indexOfSelectedItem - 1]
        }
        
        updateOpenBattleButtonState()
    }
    @IBAction func selectEngine(_ sender: NSPopUpButton) {
        if sender.indexOfSelectedItem == 0 {
            selectedEngine = nil
        } else {
            selectedEngine = engines[sender.indexOfSelectedItem - 1]
        }
        
        updateOpenBattleButtonState()
        
    }
    
    @IBAction func openBattle(_ sender: Any) {
        guard let selectedEngine = selectedEngine,
              let selectedGame = selectedGame else {
            return
        }
        
        setUIEnabled(false)
        
        let map = archiveLoader.mapArchives.first!
        
        // TODO: Add support for restrictions (password, rank, maxPlayers etc.)
        let command = CSOpenBattleCommand(isReplay: false, natType: .none, password: nil, port: 8452, maxPlayers: 32, gameHash: selectedGame.completeChecksum, rank: 0, mapHash: map.completeChecksum, engineName: "Spring", engineVersion: selectedEngine.syncVersion, mapName: map.name, title: descriptionField.stringValue, gameName: selectedGame.name)
        client.connection?.send(command, specificHandler: { [weak self] response in
            guard let self = self else { return true }
            if let _ = response as? SCOpenBattleCommand {
                self.completionHandler?()
            } else if let failure = response as? SCOpenBattleFailedCommand {
                print("Open Battle failed! \(failure.reason)")
                // TODO
            } else {
                return false
            }
            return true
        })
    }
	
}
