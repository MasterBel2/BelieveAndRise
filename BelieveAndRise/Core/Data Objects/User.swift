//
//  User.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 24/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

struct User: Sortable {
	enum PropertyKey {
		case rank
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
		let username: String
		/// Indicates whether the account is automated.
		///
		/// An automated account is usually referred to as a "Bot" in the context of the SpringRTS lobby server.
		/// This property is also referred to as a "botflag".
        #warning("""
        Whether a user account is automated should be sent as part of the log-on profile,
        not as part of the continually-updating status.
        """)
		var isAutomatedAccount: Bool?
        /// A string identifying which lobby client the user is using
        var lobbyID: String
		
	}
	
	struct Status {
		/// Indicates whether the user is AFK.
		var isAway: Bool
        var rank: Int

        static var `default`: Status {
            return Status(isAway: false, rank: -1)
        }
	}
}
