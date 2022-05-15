//
//  BattleroomViewController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 30/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa
import UberserverClientCore

/**
 A view controller for a standard client battleroom.

 The battleroom is backed by a `ColoredView` to allow drawing of background colors. Use `setViewBackgroundColor` to modify
 this property.
 */
final class BattleroomViewController: NSViewController, BattleroomHeaderViewDelegate, ReceivesBattleroomUpdates, ReceivesBattleUpdates {
    
    // MARK: - Data

    var session: UnownedQueueLocked<AuthenticatedSession>!

    #warning("Should support displaying an empty battleroom when currently not in a battle.")
    private weak var battleroom: Battleroom! {
        didSet {
            battleroom.allyTeamLists.forEach({ playerlistViewController.addSection($0) })
            playerlistViewController.addSection(battleroom.spectatorList)
        }
    }

    func setBattleroom(_ battleroom: Battleroom?) {
        executeOnMain { [weak self] in
            guard let self = self else { return }
            self.battleroom = battleroom
            
            if let battleroom = battleroom {
                if let loadedMapArchive = battleroom.battle.loadedMap {
                    self.header.minimapView.loadedMapArchive(loadedMapArchive, checksumMatch: false, usedPreferredEngineVersion: false)
                }

                battleroom.battle.addObject(self.header.minimapView)
                battleroom.addObject(self.header.minimapView)
                
                battleroom.battle.addObject(self)
                battleroom.addObject(self)
                
                self.playerlistViewController.itemViewProvider = BattleroomPlayerListItemViewProvider(battleroom: battleroom)
                
                self.chatViewController.setChannel(battleroom.channel)

                self.chatViewController.logViewController.itemViewProvider = BattleroomMessageListItemViewProvider(
                    list: battleroom.channel.messageList,
                    battleroom: battleroom
                )
            }
        }
    }

    // MARK: - Interface
    @IBOutlet var stackView: NSStackView!

    /**
     The battleroom's header view.

     Initialised on `viewDidLoad()`.
     */
    let header = BattleroomHeaderView.loadFromNib()

    /// The controller for the battleroom's chat view.
    let chatViewController = ChatViewController()
    /// The controller for the battleroom's player list
    let playerlistViewController = ListViewController()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setViewBackgroundColor(.controlBackgroundColor)

        // Header

        header.delegate = self
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)
        header.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        header.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        header.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		
		// Must be called before battleroom.displayIngameStatus
		configureAllyTeamControl()

        // Player list

        addChild(playerlistViewController)
        stackView.addArrangedSubview(playerlistViewController.view)
        playerlistViewController.view.widthAnchor.constraint(equalToConstant: 200).isActive = true

        // Chat

        addChild(chatViewController)
        stackView.addArrangedSubview(chatViewController.view)

        // Battleroom display delegates
        
        displayMapName(battleroom.battle.mapIdentification.name)
        displaySyncStatus(battleroom.battle.isSynced)
        display(isHostIngame: battleroom.isHostIngame, isPlayerIngame: battleroom.isPlayerIngame)

        chatViewController.logViewController.tableView.enclosingScrollView?.contentInsets = NSEdgeInsets(
            top: 1 * header.frame.height,
            left: 0,
            bottom: 0,
            right: 0
        )

        playerlistViewController.tableView.enclosingScrollView?.contentInsets = NSEdgeInsets(
            top: 1 * header.frame.height,
            left: 0,
            bottom: 0,
            right: 0
        )
    }

    /// Configures the ally team selector in the header view with intitial values.
	///
	/// Must be configured before new options are pushed to the control.
    private func configureAllyTeamControl() {
        for (allyNumber, _) in battleroom.allyTeamLists.enumerated().filter({ $0.element.sortedItemCount > 0 }) {
            addedTeam(named: String(allyNumber))
        }
        header.addAllyItem(BattleroomHeaderView.AllyItem(
            title: "New Team",
            action: { [weak self] in
                guard let self = self,
                    let newAllyNumber = (0..<16).first(where: { self.battleroom.allyNamesForAllyNumbers[$0] == nil })
                    else {
                        #warning("Fails silently when all 16 teams are full. Should ensure the option is removed instead.")
                    return
                }
                let myBattleStatus = self.battleroom.myBattleStatus
                self.battleroom.setBattleStatus(Battleroom.UserStatus(
                    isReady: myBattleStatus.isReady,
                    teamNumber: myBattleStatus.teamNumber,
                    allyNumber: newAllyNumber,
                    isSpectator: false,
                    handicap: myBattleStatus.handicap,
                    syncStatus: myBattleStatus.syncStatus,
                    side: myBattleStatus.side
                ))
                #warning("Need to display something better than \"New Team\" when clicking on this")
            }
        ))

        #warning("It is so cumbersome to set spectator in this way?!")
        header.addAllyItem(BattleroomHeaderView.AllyItem(
            title: "Spectator",
            action: { [weak self] in
                guard let self = self
                    else {
                    return
                }
                let myBattleStatus = self.battleroom.myBattleStatus
                self.battleroom.setBattleStatus(Battleroom.UserStatus(
                    isReady: myBattleStatus.isReady,
                    teamNumber: myBattleStatus.teamNumber,
                    allyNumber: myBattleStatus.allyNumber,
                    isSpectator: true,
                    handicap: myBattleStatus.handicap,
                    syncStatus: myBattleStatus.syncStatus,
                    side: myBattleStatus.side
                ))
            }
        ))

        let host = battleroom.battle.userList.items[battleroom.battle.founderID]
        header.hostClanField.stringValue = host?.profile.clans.first ?? ""
        header.hostNameField.stringValue = host?.profile.username ?? ""

        header.battleDescriptionField.stringValue = battleroom.battle.title
    }

    // MARK: - View Apperance

    /// Sets a background color on the view controller's view.
    ///
    /// If the view has not yet been loaded, this function will trigger its loading. Therefore it should not be loaded until after all
    /// dependencies have been loaded.
    ///
    /// This function is intended to be exposed to other UI classes only and so is not thread safe. Call only from the main thread.
    func setViewBackgroundColor(_ color: NSColor?) {
        (view as? ColoredView)?.backgroundColor = color
    }
    
    // MARK: - Battle Updates
    
    func mapDidUpdate(to map: Battle.MapIdentification) {
        displayMapName(map.name)
        header.displaySyncStatus(battleroom.battle.isSynced)
    }
    
    func loadedMapArchive(_ mapArchive: MapArchive, checksumMatch: Bool, usedPreferredEngineVersion: Bool) {
        header.displaySyncStatus(battleroom.battle.isSynced)
    }

    // MARK: - Battleroom Updates

    func display(isHostIngame: Bool, isPlayerIngame: Bool) {
        executeOnMainSync { [self] in
            if battleroom.battle.founderID == battleroom.myID {
                header.setWatchGameButtonState(.startGame)
            } else if isHostIngame {
                header.setWatchGameButtonState(.joinGame)
            } else {
                header.setWatchGameButtonState(.hidden)
            }

            header.watchGameButton.isEnabled = !isPlayerIngame
        }
    }
	
	func addedTeam(named teamName: String) {
		executeOnMain { [weak self] in
			self?._addedTeam(named: teamName)
		}
	}
	
	private func _addedTeam(named teamName: String) {
		if isViewLoaded {
			for index in 0..<(header.allyItems.count - 2) {
				// Ensure that 2 is positioned before 10.
				if Int(teamName) != nil,
				   allyItemTitle(forAllyNamed: teamName).count < header.allyItems[index].title.count {
					insertAllyOption(named: teamName, at: index)
					return
				}
				if header.allyItems[index].title > allyItemTitle(forAllyNamed: teamName) {
					// Ensure that 10 is positioned after 2.
					if Int(teamName) != nil,
					   allyItemTitle(forAllyNamed: teamName).count > header.allyItems[index].title.count {
						break
					}
					insertAllyOption(named: teamName, at: index)
					return
				}
			}
			insertAllyOption(named: teamName, at: header.allyItems.count - 2)
		}
    }
    
    private func insertAllyOption(named teamName: String, at index: Int) {
        let allyItem = BattleroomHeaderView.AllyItem(title: allyItemTitle(forAllyNamed: teamName), action: { [weak self] in
            guard let self = self else {
                return
            }
            let myBattleStatus = self.battleroom.myBattleStatus
            let newAllyNumber = self.battleroom.allyNamesForAllyNumbers.first(where: { $0.value == teamName })?.key
            self.battleroom.setBattleStatus(Battleroom.UserStatus(
                isReady: myBattleStatus.isReady,
                teamNumber: myBattleStatus.teamNumber,
                allyNumber: newAllyNumber ?? myBattleStatus.allyNumber,
                isSpectator: false,
                handicap: myBattleStatus.handicap,
                syncStatus: myBattleStatus.syncStatus,
                side: myBattleStatus.side
            ))
        })
        header.insertAllyItem(allyItem, at: index)
    }

    func removedTeam(named teamName: String) {
        executeOnMain(target: self) { _self in
            _self.header.removeAllyItem(named: _self.allyItemTitle(forAllyNamed: teamName))
        }
    }

    func displaySyncStatus(_ syncStatus: Bool) {
        executeOnMain(target: header) { header in
            header.displaySyncStatus(syncStatus)
        }
    }
	
	func displayReadySate(_ isReady: Bool) {
		executeOnMain(target: header) { header in
			header.displayReadyState(isReady)
		}
	}

    private func displayMapName(_ mapName: String) {
        executeOnMain(target: header) { header in
            header.mapNameField.stringValue = mapName
        }
    }

//    func addCustomisedMapOption(_ option: String, value: UnitsyncWrapper.InfoValue) {
//        // TODO
//    }
//
    func removeCustomisedMapOption(_ option: String) {
        // TODO
    }

    // MARK: - BattleroomHeaderViewDelegate

    func showControlPanel() {
        let viewController = BattleroomControlPanelViewController()
        let window = NSPanel(contentViewController: viewController)
        window.makeKeyAndOrderFront(self)
    }

    func startGame() {
        try? battleroom.startGame()
    }
	
	func setReadyState(_ ready: Bool) {
        Logger.log("Requesting Ready status -> \(ready)", tag: .BattleStatusUpdate)
		let myBattleStatus = battleroom.myBattleStatus
		battleroom.setBattleStatus(
			Battleroom.UserStatus(
				isReady: ready,
				teamNumber: myBattleStatus.teamNumber,
				allyNumber: myBattleStatus.allyNumber,
				isSpectator: myBattleStatus.isSpectator,
				handicap: myBattleStatus.handicap,
				syncStatus: myBattleStatus.syncStatus,
				side: myBattleStatus.side
			)
		)
	}

    // MARK: - Private helpers

    private func allyItemTitle(forAllyNamed allyName: String) -> String {
        return "Ally \(allyName)"
    }
}
