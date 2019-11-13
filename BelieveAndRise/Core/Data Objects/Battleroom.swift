//
//  Battleroom.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 24/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

protocol BattleDelegate: AnyObject {}
protocol BattleroomDelegate: BattleDelegate {
}

final class Battleroom {

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

    weak var spectatorListDisplay: ListDisplay?
    weak var allyTeamListDisplay: ListDisplay?

    weak var delegate: BattleroomDelegate?

    // MARK: - Updates

    func setUserStatus(_ userStatus: UserStatus, forUserIdentifiedBy id: Int) {
        let wasSpectator = userStatuses[id]?.isSpectator
        if wasSpectator != true {
            if let previousAllyNumber = userStatuses[id]?.allyNumber,
                userStatus.allyNumber != previousAllyNumber,
                let allyTeamList = allyTeamLists[previousAllyNumber] {
                allyTeamList.removeItem(withID: id)
                if allyTeamList.itemCount == 0 {
                    allyTeamListDisplay?.removeSection(allyTeamList)
                    allyTeamLists.removeValue(forKey: previousAllyNumber)
                }
            }
        }
        userStatuses[id] = userStatus
        if !userStatus.isSpectator {
            if let allyTeamList = allyTeamLists[userStatus.allyNumber] {
                allyTeamList.addItemFromParent(id: id)
            } else {
                let allyTeamList = List<User>(title: "AllyTeam \(userStatus.allyNumber)", sortKey: .rank, parent: battle.userList)
                allyTeamList.addItemFromParent(id: id)
                allyTeamListDisplay?.addSection(allyTeamList)
                allyTeamLists[userStatus.allyNumber] = allyTeamList
            }
        } else if wasSpectator != true {
            spectatorList.addItemFromParent(id: id)
        }
        
    }

    private func updateAllyNumber(_ userStatus: UserStatus, forUserIdentifiedBy id: Int) {

    }

    private func addStartRect(_ rect: CGRect, for allyTeam: Int) {

    }

    private func removeStartRect(for allyTeam: Int) {

    }

    // MARK: - Lifecycle
	
	init(battle: Battle, channel: Channel, hashCode: Int32) {
		self.battle = battle
		self.hashCode = hashCode
		self.channel = channel
        spectatorList = List<User>(title: "Spectators", sortKey: .rank, parent: battle.userList)
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
