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

protocol BattleroomDisplay: MinimapDisplay, BattleroomGameInfoDisplay, BattleroomMapInfoDisplay {

}

final class Battleroom: BattleDelegate, ListDelegate {

    // MARK: - Data

    let battle: Battle
    let channel: Channel

    var allyTeamLists: [Int : List<User>] = [:]
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

    weak var spectatorListDisplay: ListDisplay?
    weak var allyTeamListDisplay: ListDisplay?

    weak var minimapDisplay: MinimapDisplay?
    weak var mapInfoDisplay: BattleroomMapInfoDisplay?
    weak var gameInfoDisplay: BattleroomGameInfoDisplay?

    // MARK: - Player information

    private let myID: Int
    private let scriptPassword: Int

    var myBattleStatus: Battleroom.UserStatus {
        return userStatuses[myID] ?? UserStatus.default
    }

    var myColor: Int32 {
        return colors[myID] ?? Int32(myID) & 0x00FFFFFF
    }

    // MARK: - Updates

    /// Sets the status for a user, as specified by their ID. 
    func setUserStatus(_ newUserStatus: UserStatus, forUserIdentifiedBy id: Int) {
        // Ally/spectator
        if let previousUserStatus = userStatuses[id] {
            if !previousUserStatus.isSpectator {
                if newUserStatus.isSpectator {
                    // !isSpectator -> isSpectator
                    removeUser(identifiedBy: id, fromAllyTeam: previousUserStatus.allyNumber)
                    spectatorList.addItemFromParent(id: id)
                } else if previousUserStatus.allyNumber != newUserStatus.allyNumber {
                    // !wasSpectator && allyTeam != allyTeam
                    removeUser(identifiedBy: id, fromAllyTeam: previousUserStatus.allyNumber)
                    addUser(identifiedBy: id, toAllyTeam: newUserStatus.allyNumber)
                }
            } else {
                if !newUserStatus.isSpectator {
                    // wasSpectator -> allyteam
                    spectatorList.removeItem(withID: id)
                    addUser(identifiedBy: id, toAllyTeam: newUserStatus.allyNumber)
                }
            }
        }
        userStatuses[id] = newUserStatus
    }

    private func addUser(identifiedBy id: Int, toAllyTeam allyTeam: Int) {
        if let allyTeamList = allyTeamLists[allyTeam] {
            allyTeamList.addItemFromParent(id: id)
        } else {
            let allyTeamList = List<User>(title: "AllyTeam \(allyTeam)", sortKey: .rank, parent: battle.userList)
            allyTeamList.addItemFromParent(id: id)
            allyTeamListDisplay?.addSection(allyTeamList)
            allyTeamLists[allyTeam] = allyTeamList
        }
    }

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

    private func updateAllyNumber(_ userStatus: UserStatus, forUserIdentifiedBy id: Int) {

    }

    private func addStartRect(_ rect: CGRect, for allyTeam: Int) {
        startRects[allyTeam] = rect
        minimapDisplay?.addStartRect(rect, for: allyTeam)
    }

    private func removeStartRect(for allyTeam: Int) {
        startRects.removeValue(forKey: allyTeam)
        minimapDisplay?.removeStartRect(for: allyTeam)
    }

    // MARK: - Map

    func mapDidUpdate(to map: Battle.Map) {
        if let (mapInfo, _, _) = resourceManager.infoForMap(named: map.name, preferredChecksum: map.hash, preferredEngineVersion: battle.engineVersion) {
            guard let (imageData, dimension) = resourceManager.minimapData(forMapNamed: map.name) else {
                minimapDisplay?.displayMapUnknown()
                return
            }
            minimapDisplay?.displayMap(imageData, dimension: dimension, realWidth: mapInfo.width, realHeight: mapInfo.height)
        } else {
            minimapDisplay?.displayMapUnknown()
        }
    }

    // MARK: - ListDelegate

    func list(_ list: ListProtocol, didAddItemWithID id: Int, at index: Int) {}

    func list(_ list: ListProtocol, didMoveItemFrom index1: Int, to index2: Int) {}

    func list(_ list: ListProtocol, didRemoveItemAt index: Int) {}
    func list(_ list: ListProtocol, itemWasUpdatedAt index: Int) {}

    // MARK: - Lifecycle
	
    init(battle: Battle, channel: Channel, hashCode: Int32, resourceManager: ResourceManager, myID: Int) {
		self.battle = battle
		self.hashCode = hashCode
		self.channel = channel
        spectatorList = List<User>(title: "Spectators", sortKey: .rank, parent: battle.userList)
        self.resourceManager = resourceManager
        self.myID = 0
        self.scriptPassword = myID.hashValue

        battle.delegate = self
	}

    deinit {
        spectatorList.sortedItemsByID.forEach(spectatorList.removeItem(withID:))
        if let minimapDisplay = minimapDisplay {
            allyTeamLists.map({ $0.key }).forEach(minimapDisplay.removeStartRect(for:))
        }
        allyTeamLists.map({ $0.value }).forEach({ list in
            list.sortedItemsByID.forEach(list.removeItem(withID:))
        })
    }

    // MARK: - Nested Types
	
	class Bot {
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
