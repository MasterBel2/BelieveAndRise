//
//  Battleroom.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 24/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

protocol BattleroomMapInfoDisplay: AnyObject {
    func addCustomisedMapOption(_ option: String, value: UnitsyncWrapper.InfoValue)
    func removeCustomisedMapOption(_ option: String)
}

protocol BattleroomGameInfoDisplay: AnyObject {
    func addCustomisedGameOption(_ option: String, value: UnitsyncWrapper.InfoValue)
    func removeCustomisedGameOption(_ option: String)
}

protocol BattleroomDisplay: AnyObject {
    /// Notifies the display of the host's and user's updated in-game states.
    func display(isHostIngame: Bool, isPlayerIngame: Bool)
    /// Notifiies the display that a new team was added.
    func addedTeam(named teamName: String)
    /// Notifies the display that a team was removed.
    func removedTeam(named teamName: String)
}

final class Battleroom: BattleDelegate, ListDelegate {

    // MARK: - Data

    /// The battleroom's associated battle.
    let battle: Battle
    /// The battleroom's associated channel.
    let channel: Channel

    private(set) var allyTeamLists: [Int : List<User>] = [:]
    let spectatorList: List<User>
    var bots: [Bot] = []

    private(set) var startRects: [Int : CGRect] = [:]

	/// Updated by CLIENTBATTLESTATUS command
	private(set) var userStatuses: [Int : UserStatus] = [:]
    /// Updated by CLIENTBATTLESTATUS command
	var colors: [Int : Int32] = [:]
	/// Updated by SETSCRIPTTAGS command

	var scriptTags: [ScriptTag] = []
	/// Computed by the host's unitsync using the current map, game, and other dependencies.
	/// It is used to check that the client has correct non-corrupt downloads of the required content.
    var disabledUnits: [String] = []

    /// A hash code taken from the map, game, and engine. Calculated by Unitsync.
    var hashCode: Int32

    // MARK: - Dependencies

    let resourceManager: ResourceManager

    weak var spectatorListDisplay: ListDisplay? {
        didSet {
            spectatorListDisplay?.addSection(spectatorList)
        }
    }

    // MARK: - Displays

    weak var allyTeamListDisplay: ListDisplay?

    weak var minimapDisplay: MinimapDisplay?
    weak var mapInfoDisplay: BattleroomMapInfoDisplay?
    weak var gameInfoDisplay: BattleroomGameInfoDisplay?
    weak var generalDisplay: BattleroomDisplay?

    // MARK: - Player information

    let myID: Int

    var myBattleStatus: Battleroom.UserStatus {
        return userStatuses[myID] ?? UserStatus.default
    }

    var myColor: Int32 {
        return colors[myID] ?? Int32(myID.hashValue & 0x00FFFFFF)
    }
    /// Whether the player is ingame.
    private var isPlayerIngame: Bool {
        return battle.userList.items[myID]?.status.isIngame ?? false
    }

    /// Whether the host is ingame.
    private var isHostIngame: Bool {
        return battle.userList.items[battle.founderID]?.status.isIngame ?? false
    }

    // MARK: - Updates

    func displayIngameStatus() {
        generalDisplay?.display(isHostIngame: isHostIngame, isPlayerIngame: isPlayerIngame)
    }

    /// Sets the status for a user, as specified by their ID. 
    func setUserStatus(_ newUserStatus: UserStatus, forUserIdentifiedBy userID: Int) {
        // Ally/spectator
        if let previousUserStatus = userStatuses[userID] {
            if !previousUserStatus.isSpectator {
                if newUserStatus.isSpectator {
                    // !isSpectator -> isSpectator
                    removeUser(identifiedBy: userID, fromAllyTeam: previousUserStatus.allyNumber)
                    spectatorList.addItemFromParent(id: userID)
                } else if previousUserStatus.allyNumber != newUserStatus.allyNumber {
                    // !wasSpectator && allyTeam != allyTeam
                    removeUser(identifiedBy: userID, fromAllyTeam: previousUserStatus.allyNumber)
                    addUser(identifiedBy: userID, toAllyTeam: newUserStatus.allyNumber)
                }
            } else {
                if !newUserStatus.isSpectator {
                    // wasSpectator -> allyteam
                    spectatorList.removeItem(withID: userID)
                    addUser(identifiedBy: userID, toAllyTeam: newUserStatus.allyNumber)
                }
            }
        } else if newUserStatus.isSpectator {
            spectatorList.addItemFromParent(id: userID)
        } else {
            addUser(identifiedBy: userID, toAllyTeam: newUserStatus.allyNumber)
        }

        // Update the data
        userStatuses[userID] = newUserStatus

        // Update the view
        battle.userList.respondToUpdatesOnItem(identifiedBy: userID)
    }

    /// Adds a user to an allyteam, creating a new list if one was not already created.
    private func addUser(identifiedBy id: Int, toAllyTeam allyTeam: Int) {
        if let allyTeamList = allyTeamLists[allyTeam] {
            allyTeamList.addItemFromParent(id: id)
        } else {
            let allyTeamList = List<User>(title: "AllyTeam \(allyTeam)", sortKey: .rank, parent: battle.userList)
            allyTeamList.addItemFromParent(id: id)
            allyTeamListDisplay?.addSection(allyTeamList)
            allyTeamLists[allyTeam] = allyTeamList

            generalDisplay?.addedTeam(named: String(allyTeam))
        }
    }

    /// Removes the specified user from the specified allyteam, removing the allyteam from the list if there are no longer any players in
    /// the allyteam
    private func removeUser(identifiedBy id: Int, fromAllyTeam allyTeam: Int) {
        guard let allyTeamList = allyTeamLists[allyTeam] else {
            return
        }
        allyTeamList.removeItem(withID: id)
        if allyTeamList.itemCount == 0 {
            allyTeamLists.removeValue(forKey: allyTeam)
            allyTeamListDisplay?.removeSection(allyTeamList)
        }
    }

    /// Adds a start rect.
    func addStartRect(_ rect: CGRect, for allyTeam: Int) {
        startRects[allyTeam] = rect
        minimapDisplay?.addStartRect(rect, for: allyTeam)
    }

    /// Removes a start rect.
    func removeStartRect(for allyTeam: Int) {
        startRects.removeValue(forKey: allyTeam)
        minimapDisplay?.removeStartRect(for: allyTeam)
    }

    // MARK: - Map

    /// Updates sync status, and loads minimap if the map is found.
    func mapDidUpdate(to map: Battle.Map) {
        if let (mapInfo, checksumMatch, _) = resourceManager.infoForMap(named: map.name, preferredChecksum: map.hash, preferredEngineVersion: battle.engineVersion) {
            if !checksumMatch {
                debugOnlyPrint("Warning: Map checksums do not match.")
            }
            resourceManager.loadMinimapData(forMapNamed: map.name, mipLevels: Range(0...5)) { [weak self] result in
                guard let self = self,
                    let minimapDisplay = self.minimapDisplay else {
                    return
                }
                guard let (imageData, dimension) = result else {
                    minimapDisplay.displayMapUnknown()
                    return
                }
                minimapDisplay.displayMap(imageData, dimension: dimension, realWidth: mapInfo.width, realHeight: mapInfo.height)
                minimapDisplay.removeAllStartRects()
                self.startRects.forEach({
                    minimapDisplay.addStartRect($0.value, for: $0.key)
                })

            }
            minimapDisplay?.displayMap([0], dimension: 1, realWidth: mapInfo.width, realHeight: mapInfo.height)
        } else {
            minimapDisplay?.displayMapUnknown()
            resourceManager.download(.map(name: map.name), completionHandler: { [weak self] successful in
                guard let self = self else {
                    return
                }
                if successful {
                    self.mapDidUpdate(to: map)
                } else {
                    print("Unsuccessful download of map \(map.name)")
                }
            })
        }
    }

    // MARK: - ListDelegate
    // The Battleroom is the delegate of the battle's userlist. Updates happen there.

    func list(_ list: ListProtocol, didAddItemWithID id: Int, at index: Int) {}

    func list(_ list: ListProtocol, didMoveItemFrom index1: Int, to index2: Int) {}

    func list(_ list: ListProtocol, didRemoveItemAt index: Int) {}
    func list(_ list: ListProtocol, itemWasUpdatedAt index: Int) {
        if list.sortedItemsByID[index] == myID {
            displayIngameStatus()
        }
    }

    // MARK: - Lifecycle
	
    init(battle: Battle, channel: Channel, hashCode: Int32, resourceManager: ResourceManager, myID: Int) {
		self.battle = battle
		self.hashCode = hashCode
		self.channel = channel
        spectatorList = List<User>(title: "Spectators", sortKey: .rank, parent: battle.userList)
        self.resourceManager = resourceManager
        self.myID = 0

        battle.delegate = self
        battle.userList.delegate = self
	}

    deinit {
        spectatorListDisplay?.removeSection(spectatorList)
        if let minimapDisplay = minimapDisplay {
            allyTeamLists.map({ $0.key }).forEach(minimapDisplay.removeStartRect(for:))
        }
        allyTeamLists.map({ $0.value }).forEach({ list in
            allyTeamListDisplay?.removeSection(list)
        })
    }

    // MARK: - Nested Types
	
	final class Bot {
		let name: String
		let owner: User
		var status: UserStatus
		var color: Int32
		
		init(name: String, owner: User, status: UserStatus, color: Int32) {
			self.name = name
			self.owner = owner
			self.status = status
			self.color = color
		}
	}
	
	struct UserStatus {
		let isReady: Bool
		let teamNumber: Int
		let allyNumber: Int
		let isSpectator: Bool
		let handicap: Int
		let syncStatus: SyncStatus
		let side: Int
		
		enum SyncStatus: Int {
			case unknown = 0
			case synced = 1
			case unsynced = 2
		}

        static var `default`: UserStatus {
            return UserStatus(
                isReady: false,
                teamNumber: 1,
                allyNumber: 1,
                isSpectator: true,
                handicap: 0,
                syncStatus: .unknown,
                side: 0
            )
        }

        init(isReady: Bool, teamNumber: Int, allyNumber: Int, isSpectator: Bool, handicap: Int = 0, syncStatus: SyncStatus, side: Int) {
            self.isReady = isReady
            self.teamNumber = teamNumber
            self.allyNumber = allyNumber
            self.isSpectator = isSpectator
            self.handicap = handicap
            self.syncStatus = syncStatus
            self.side = side
        }
		
		init?(statusValue: Int) {
			isReady = (statusValue & 0b10) == 0b10
			teamNumber = (statusValue & 0b111100) >> 2
			allyNumber = (statusValue & 0b1111000000) >> 6
			isSpectator = (statusValue & 0b10000000000) != 0b10000000000
			handicap = (statusValue & 0b111111100000000000) >> 11
			
			let syncValue = (statusValue & 0b110000000000000000000000) >> 22
			
			switch syncValue {
			case 1:
				syncStatus = .synced
			case 2:
				syncStatus = .unsynced
			default:
				syncStatus = .unknown
			}
			
			self.side = (statusValue & 0b1111000000000000000000000000) >> 24
		}
		
		var integerValue: Int32 {
			var battleStatus: Int32 = 0
			if isReady {
				battleStatus += 2 // 2^1
			}
			battleStatus += Int32(teamNumber*4) // 2^2
			battleStatus += Int32(allyNumber*64) // 2^6
			if !isSpectator {
				battleStatus += 1024// 2^10
			}
			battleStatus += Int32(syncStatus.rawValue*4194304) // 2^22
			battleStatus += Int32(side*16777216) // 2^24
			return battleStatus
		}
	}
	enum ScriptTag {
		
	}
}
