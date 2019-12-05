//
//  User.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 24/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

final class User: Sortable {
	enum PropertyKey {
		case rank
	}
	
	init(profile: Profile) {
		self.profile = profile
	}
	
	/// The user's profile as contained on the server
	let profile: Profile
    var status = Status.default
	
	// MARK: - Sortable
	
	/// The user's ID.
	var id: Int { return profile.id }
	
	func relationTo(_ other: User, forSortKey sortKey: User.PropertyKey) -> ValueRelation {
		switch sortKey {
		case .rank:
			return ValueRelation(value1: status.rank, value2: other.status.rank)
		}
	}
	
	struct Profile {
		let id: Int
		let fullUsername: String
        let clans: [String]
        let username: String
        /// A string identifying which lobby client the user is using
        var lobbyID: String

        init(id: Int, fullUsername: String, lobbyID: String) {
            self.id = id
            self.lobbyID = lobbyID
            self.fullUsername = fullUsername

            guard let regex = try? NSRegularExpression(pattern: "\\[.+?\\]") else {
                self.clans = []
                username = fullUsername
                return
            }

            let tagRanges = regex.matches(
                in: fullUsername,
                range: NSRange(fullUsername.startIndex..., in: fullUsername)
            ).compactMap({ Range($0.range, in: fullUsername) })

            self.clans = tagRanges.map({ range in String(fullUsername[range]) })

            var username = ""
            var startIndex = fullUsername.startIndex
            if tagRanges.count > 0 {
                for tagRange in tagRanges {
                    username.append(String(fullUsername[startIndex..<tagRange.lowerBound]))
                    startIndex = tagRange.upperBound
                }
            }
            username.append(String(fullUsername[startIndex..<fullUsername.endIndex]))
            self.username = username
        }
    }

    struct Status {
        /// Indicates whether the user is AFK.
        let isAway: Bool
        let isIngame: Bool
        let rank: Int
        let isModerator: Bool
        /// Indicates whether the account is automated.
		///
		/// An automated account is usually referred to as a "Bot" in the context of the SpringRTS lobby server.
		/// This property is also referred to as a "botflag".
		var isAutomatedAccount: Bool
		#warning("""
        Whether a user account is automated should be sent as part of the log-on profile,
        not as part of the continually-updating status.
        """)

        static var `default`: Status {
            return Status(rawValue: 0)
        }
		
		init(isAway: Bool, isIngame: Bool, rank: Int, isModerator: Bool, isAutomatedAccount: Bool) {
			self.isAway = isAway
			self.isIngame = isIngame
			self.rank = rank
			self.isModerator = isModerator
			self.isAutomatedAccount = isAutomatedAccount
		}
		
		init(rawValue: Int) {
			isIngame = (rawValue & 0b01) == 1
			isAway = (rawValue & 0b10) >> 1 == 1
			rank = (rawValue & 0b11100) >> 2
			isModerator = (rawValue & (1 << 4)) == 1
			isAutomatedAccount = (rawValue & (1 << 5)) == 1
		}
		
		var rawValue: Int {
			var value = 0
			value += isIngame ? 1 : 0
			value += isIngame ? 2 : 0
			value += rank << 2
			value += isModerator ? 8 : 0
			value += isAutomatedAccount ? 16 : 0
			
			return value
		}
	}
}
