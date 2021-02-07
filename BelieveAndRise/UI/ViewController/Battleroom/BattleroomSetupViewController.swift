//
//  BattleroomSetupViewController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 28/7/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa
import UberserverClientCore

class BattleroomSetupViewController: NSViewController {
	
	var client: Client! {
		didSet {
			archiveLoader = client.resourceManager.archiveLoader
		}
	}
	private var archiveLoader: DescribesArchivesOnDisk!
	
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
		
		// If the archive loader is refreshed, it will corrupt the available options.
		// So cache the options that are available when setting up the UI.
		engines = archiveLoader.engines
		engines.forEach({ engineSelectionBox.addItem(withTitle: $0.version) })
		
		games = archiveLoader.modArchives
		games.forEach({ gameSelectionBox.addItem(withTitle: $0.name )})
		
		setUIEnabled(true)
		updateOpenBattleButtonState()
    }
	
	
	private var uiIsEnabled = true
	
	private var engines: [Engine] = []
	private var selectedEngine: Engine?
	
	private var games: [ModArchive] = []
	private var selectedGame: ModArchive?
	
	private func updateOpenBattleButtonState() {
		openBattleButton.isEnabled = uiIsEnabled
			&& selectedEngine != nil
			&& selectedGame != nil
			&& descriptionField.stringValue != ""
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
		guard let selectedEngine = selectedEngine else { return }
		spinner.isHidden = false
		spinner.startAnimation(self)
		
		setUIEnabled(false)
		
		let map = archiveLoader.mapArchives.first!
		let game = archiveLoader.modArchives.first(where: { $0.name.contains("Balanced Annihilation") })!
		
		// TODO: Add support for restrictions (password, rank, maxPlayers etc.)
		let command = CSOpenBattleCommand(isReplay: false, natType: .none, password: nil, port: 8452, maxPlayers: 32, gameHash: game.completeChecksum, rank: 0, mapHash: map.completeChecksum, engineName: "Spring", engineVersion: selectedEngine.syncVersion, mapName: map.name, title: descriptionField.stringValue, gameName: game.name)
		client.server?.send(command)
	}
	
	func setUIEnabled(_ isEnabled: Bool) {
		uiIsEnabled = isEnabled
		spinner.isHidden = isEnabled
		engineSelectionBox.isEnabled = isEnabled
		gameSelectionBox.isEnabled = isEnabled
		descriptionField.isEnabled = isEnabled
		openBattleButton.isEnabled = isEnabled
	}
	
	
}
