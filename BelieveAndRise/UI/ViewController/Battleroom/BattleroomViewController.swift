//
//  BattleroomViewController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 30/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

/**
 A view controller for a standard client battleroom.

 The battleroom is backed by a `ColoredView` to allow drawing of background colors. Use `setViewBackgroundColor` to modify
 this property.
 */
final class BattleroomViewController: NSViewController, BattleroomDisplay, BattleroomMapInfoDisplay, BattleroomHeaderViewDelegate {

    // MARK: - Dependencies

    weak var battleController: BattleController!
    
    // MARK: - Data

    #warning("Should support displaying an empty battleroom when currently not in a battle.")
    weak var battleroom: Battleroom! {
        didSet {
            executeOnMain {
                playerlistViewController.itemViewProvider = DefaultPlayerListItemViewProvider(list: battleroom.battle.userList)
                
                battleroom.allyTeamListDisplay = playerlistViewController
                battleroom.spectatorListDisplay = playerlistViewController
                
                chatViewController.setChannel(battleroom.channel)
            }
        }
    }

    // MARK: - Interface
    @IBOutlet var stackView: NSStackView!

    /**
     The battleroom's header view.

     Initialised on `viewDidLoad()`.
     */
    private(set) var header: BattleroomHeaderView!

    /// The controller for the battleroom's chat view.
    let chatViewController = ChatViewController()
    /// The controller for the battleroom's player list
    let playerlistViewController = ListViewController()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Header

        let header = BattleroomHeaderView.loadFromNib()
        header.delegate = self
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)
        header.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        header.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        header.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        self.header = header

        // Player list

        addChild(playerlistViewController)
        stackView.addArrangedSubview(playerlistViewController.view)
        playerlistViewController.view.widthAnchor.constraint(equalToConstant: 200).isActive = true
        playerlistViewController.itemViewProvider = BattleroomPlayerListItemViewProvider(battleroom: battleroom)

        // Chat

        addChild(chatViewController)
        stackView.addArrangedSubview(chatViewController.view)

        chatViewController.logViewController.itemViewProvider = BattleroomMessageListItemViewProvider(
            list: battleroom.channel.messageList,
            battleroom: battleroom
        )

        // Battleroom display delegates

        battleroom.minimapDisplay = header.minimapView
        battleroom.generalDisplay = self
        battleroom.mapInfoDisplay = self
        
        // FIXME: Hacky solution to the way map loading & Stuff currently works.
        battleroom.mapDidUpdate(to: battleroom.battle.map)
        battleroom.displayIngameStatus()

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

        // Something

        configureAllyTeamControl()
    }

    /// Configures the ally team selector in the header view with intitial values.
    private func configureAllyTeamControl() {
        for (allyNumber, _) in battleroom.allyTeamLists.enumerated().filter({ $0.element.itemCount > 0 }) {
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
                self.battleController.setBattleStatus(Battleroom.UserStatus(
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
                self.battleController.setBattleStatus(Battleroom.UserStatus(
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

    // MARK: - Battleroom Display

    func display(isHostIngame: Bool, isPlayerIngame: Bool) {
        executeOnMain {
            if !isHostIngame {
                header.setWatchGameButtonState(.hidden)
            } else {
                header.setWatchGameButtonState(isPlayerIngame ? .disabled : .enabled)
            }
        }
    }

    func addedTeam(named teamName: String) {
        executeOnMain {
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
        executeOnMain {
            let allyItem = BattleroomHeaderView.AllyItem(title: allyItemTitle(forAllyNamed: teamName), action: { [weak self] in
                guard let self = self else {
                    return
                }
                let myBattleStatus = self.battleroom.myBattleStatus
                let newAllyNumber = self.battleroom.allyNamesForAllyNumbers.first(where: { $0.value == teamName })?.key
                self.battleController.setBattleStatus(Battleroom.UserStatus(
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
    }

    func removedTeam(named teamName: String) {
        executeOnMain(target: header) { header in
            header.removeAllyItem(named: allyItemTitle(forAllyNamed: teamName))
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

    // MARK: - BattleroomMapInfoDisplay

    func displayMapName(_ mapName: String) {
        executeOnMain(target: header) { header in
            header.mapNameField.stringValue = mapName
        }
    }

    func addCustomisedMapOption(_ option: String, value: UnitsyncWrapper.InfoValue) {
        // TODO
    }

    func removeCustomisedMapOption(_ option: String) {
        // TODO
    }

    // MARK: - BattleroomHeaderViewDelegate

    func startGame() {
        battleController.startGame()
    }
	
	func setReadyState(_ ready: Bool) {
        Logger.log("Requesting Ready status -> \(ready)", tag: .BattleStatusUpdate)
		let myBattleStatus = battleroom.myBattleStatus
		battleController.setBattleStatus(
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
