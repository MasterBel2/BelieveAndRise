//
//  BattleroomViewController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 13/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

class BattleroomViewController: NSViewController {

    // MARK: - Outlets

    @IBOutlet var stackView: NSStackView!
    @IBOutlet weak var infoView: BattleroomInfoView!
	@IBOutlet weak var minimapView: MinimapView!
    let spectatorListViewController = ListViewController()
    let allyTeamListViewController = ListViewController()

    // MARK: - Data

    var battleroom: Battleroom! {
        didSet {
            battleroom.allyTeamListDisplay = allyTeamListViewController
            battleroom.spectatorListDisplay = spectatorListViewController

            allyTeamListViewController.itemViewProvider = DefaultPlayerListItemViewProvider(list: battleroom.battle.userList)
            spectatorListViewController.itemViewProvider = DefaultPlayerListItemViewProvider(list: battleroom.battle.userList)
        }
    }

    // MARK: - Lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()

        configureListViews()
        configureInfoViews()
    }

    private func configureInfoViews() {
        battleroom.minimapDisplay = minimapView
        battleroom.mapInfoDisplay = infoView
        battleroom.gameInfoDisplay = infoView
    }

    /**
     Handles the setup of the spectatorListViewController and allyTeamListViewController.
     */
    private func configureListViews() {
        addChild(allyTeamListViewController)
        stackView.addArrangedSubview(allyTeamListViewController.view)
        allyTeamListViewController.tableView.enclosingScrollView?.autohidesScrollers = true
        addChild(spectatorListViewController)
        stackView.addArrangedSubview(spectatorListViewController.view)

        spectatorListViewController.view.widthAnchor.constraint(equalTo: allyTeamListViewController.view.widthAnchor).isActive = true
    }

    // MARK: - Battleroom Delegate

}

final class BattleroomInfoView: NSView, BattleroomMapInfoDisplay, BattleroomGameInfoDisplay {
    func addCustomisedMapOption(_ option: String, value: UnitsyncWrapper.InfoValue) {}

    func removeCustomisedMapOption(_ option: String) {}

    func addCustomisedGameOption(_ option: String, value: UnitsyncWrapper.InfoValue) {}

    func removeCustomisedGameOption(_ option: String) {}
}
