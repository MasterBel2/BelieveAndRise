//
//  ListSelectionHandler.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 13/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation
import UberserverClientCore
import SpringRTSReplayHandling
import SpringRTSStartScriptHandling
import ServerAddress

/// Executes an action corresponding to a selection on the behalf of a list.
protocol ListSelectionHandler {
	func primarySelect(itemIdentifiedBy id: Int)
	func secondarySelect(itemIdentifiedBy id: Int)
}

extension ListSelectionHandler {
	func primarySelect(itemIdentifiedBy id: Int) {}
	func secondarySelect(itemIdentifiedBy id: Int) {}
}

/// Executes select actions for a battle list.
struct DefaultBattleListSelectionHandler: ListSelectionHandler {
	
	let battlelist: List<Battle>
    weak var client: AuthenticatedSession?
    
    init(client: AuthenticatedSession?, battlelist: List<Battle>) {
        self.battlelist = battlelist
        self.client = client
    }

	public func primarySelect(itemIdentifiedBy id: Int) {
		client?.joinBattle(id)
	}
	
	public func secondarySelect(itemIdentifiedBy id: Int) {
		primarySelect(itemIdentifiedBy: id)
	}
}

/// Executes select actions for a list of replays.
struct ReplayListSelectionHandler: ListSelectionHandler {

    public let replayList: List<Replay>
    public let resourceManager: ResourceManager

    public func primarySelect(itemIdentifiedBy id: Int) {
		if let first = replayList.items[id] {
            resourceManager.loadEngine(version: first.header.springVersion, shouldDownload: false) { result in
                switch result {
                case .success(let engine):
                    let demoSpecification = first.gameSpecification
                    let newSpecification = GameSpecification(
                        allyTeams: demoSpecification.allyTeams,
                        spectators: demoSpecification.spectators,
                        demoFile: first.fileURL,
                        hostConfig: HostConfig(
                            userID: nil,
                            username: "Viewer",
                            type: .user(lobbyName: "BelieveAndRise"), // TODO: Use the user's logged-in name if possible
                            address: ServerAddress(location: "", port: 8452),
                            rank: nil,
                            countryCode: nil
                        ),
                        startConfig: demoSpecification.startConfig,
                        mapName: demoSpecification.mapName,
                        mapHash: demoSpecification.mapHash,
                        gameType: demoSpecification.gameType,
                        modHash: demoSpecification.modHash,
                        gameStartDelay: demoSpecification.gameStartDelay,
                        mapOptions: demoSpecification.mapOptions,
                        modOptions: demoSpecification.modOptions,
                        restrictions: demoSpecification.restrictions
                    )
                    
                    try? engine.launchGame(script: newSpecification, doRecordDemo: false, completionHandler: nil)
                default:
                    return
                }
            }
		}
    }
}

struct ChatSidebarSelectionHandler: ListSelectionHandler {
	func primarySelect(itemIdentifiedBy id: Int) {
		let channel = channelList.items[id] ?? privateMessageList.items[id] ?? forwardedMessageList.items[id]
		chatViewController.setChannel(channel)
	}

	let channelList: List<Channel>
	let privateMessageList: List<Channel>
	let forwardedMessageList: List<Channel>
	let chatViewController: ChatViewController
}
