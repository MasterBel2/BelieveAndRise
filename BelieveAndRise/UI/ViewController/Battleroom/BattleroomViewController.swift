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

    var battleController: BattleController!

    // MARK: - Data

    #warning("Should support displaying an empty battleroom when currently not in a battle.")
    var battleroom: Battleroom! {
        didSet {
            playerlistViewController.itemViewProvider = DefaultPlayerListItemViewProvider(list: battleroom.battle.userList)

            battleroom.allyTeamListDisplay = playerlistViewController
            battleroom.spectatorListDisplay = playerlistViewController

            chatViewController.setChannel(battleroom.channel)
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
        for (key, _) in battleroom.allyTeamLists {
            addedTeam(named: String(key))
        }
        header.addAllyItem(BattleroomHeaderView.AllyItem(
            title: "New Team",
            action: { [weak self] in
                guard let self = self,
                    let newAllyNumber = (0..<16).filter({ self.battleroom.allyTeamLists[$0] != nil }).first
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
    func setViewBackgroundColor(_ color: NSColor?) {
        (view as! ColoredView).backgroundColor = color
    }

    // MARK: - Battleroom Display

    func display(isHostIngame: Bool, isPlayerIngame: Bool) {
        executeOnMain(target: self) {
            if !isHostIngame {
                $0.header.setWatchGameButtonState(.hidden)
            } else {
                $0.header.setWatchGameButtonState(isPlayerIngame ? .disabled : .enabled)
            }
        }
    }

    func addedTeam(named teamName: String) {
        executeOnMain(target: self) { (viewController: BattleroomViewController) -> Void in
            viewController.header.addAllyItem(BattleroomHeaderView.AllyItem(title: "Ally \(teamName)", action: { [weak viewController] in
                guard let viewController = viewController else {
                    return
                }
                let myBattleStatus = viewController.battleroom.myBattleStatus
                viewController.battleController.setBattleStatus(Battleroom.UserStatus(
                    isReady: myBattleStatus.isReady,
                    teamNumber: myBattleStatus.teamNumber,
                    allyNumber: Int(teamName) ?? myBattleStatus.allyNumber,
                    isSpectator: false,
                    handicap: myBattleStatus.handicap,
                    syncStatus: myBattleStatus.syncStatus,
                    side: myBattleStatus.side
                ))
            }))
        }
    }

    func removedTeam(named teamName: String) {
        executeOnMain(target: header) { header in
            header.removeAllyItem(named: "Ally \(teamName)")
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
}
