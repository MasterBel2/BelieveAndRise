//
//  BattleCommands.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 12/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/**
 Sent by a client requesting to join a battle.
*/
struct CSJoinBattleCommand: CSCommand {
	
	let battleID: Int
	let password: String?
	/// A random, client-generated string (which is used to avoid account spoofing ingame, and will appear in script.txt).
	/// Note that if this argument is sent, a password must be sent too. If the battle is not passworded then an empty password should be sent.
	let scriptPassword: String?
	
	// MARK: - Manual Construction
	
	init(battleID: Int, password: String?, scriptPassword: String?) {
		self.battleID = battleID
		self.password = password
		self.scriptPassword = scriptPassword
	}
	
	// MARK: - CSCommand
	
	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 0, optionalWords: 2, optionalSentences: 0),
			let battleID = Int(words[0]) else {
			return nil
		}
		self.battleID = battleID
		if words.count > 1 {
			password = words[1]
			scriptPassword = words.count == 3 ? words[2] : nil
		} else {
			password = nil
			scriptPassword = nil
		}
	}
	
	func execute(on server: LobbyServer) {
		#warning("TODO")
	}
	
	var description: String {
		var string = "JOINBATTLE \(battleID)"
		if let password = password {
			string += " \(password)"
			if let scriptPassword = scriptPassword {
				string += " \(scriptPassword)"
			}
		}
		return string
	}
}

/**
Sent by the client when he leaves a battle.

When this command is by the founder of a battle, it notifies that the battle is now closed.

If sent by the founder, the server responds with a BATTLECLOSED command.
*/
struct CSLeaveBattleCommand: CSCommand {
	
	// MARK: - Manual Construction
	
	init() {}
	
	// MARK: - CSCommand
	
	init?(description: String) {}
	
	func execute(on server: LobbyServer) {}
	
	var description: String {
		return "LEAVEBATTLE"
	}
}

/**
 Sent by a client to the server, telling him his battle status changed.

 # String Representation

 battleStatus: An integer, but with limited range: 0..2147483647 (use signed int and consider only positive values and zero) This number is sent as text. Each bit has its meaning:
 - b0 = undefined (reserved for future use)
 - b1 = ready (0=not ready, 1=ready)
 - b2..b5 = team no. (from 0 to 15. b2 is LSB, b5 is MSB)
 - b6..b9 = ally team no. (from 0 to 15. b6 is LSB, b9 is MSB)
 - b10 = mode (0 = spectator, 1 = normal player)
 - b11..b17 = handicap (7-bit number. Must be in range 0..100). Note: Only host can change handicap values of the players in the battle (with HANDICAP command). These 7 bits are always ignored in this command. They can only be changed using HANDICAP command.
 - b18..b21 = reserved for future use (with pre 0.71 versions these bits were used for team color index)
 - b22..b23 = sync status (0 = unknown, 1 = synced, 2 = unsynced)
 - b24..b27 = side (e.g.: arm, core, tll, ... Side index can be between 0 and 15, inclusive)
 - b28..b31 = undefined (reserved for future use)


 myTeamColor: Should be a 32-bit signed integer in decimal form (e.g. 255 and not FF) where each color channel should occupy 1 byte (e.g. in hexdecimal: $00BBGGRR, B = blue, G = green, R = red). Example: 255 stands for $000000FF.

 # Response
 The status change will communicated to relevant users via the CLIENTBATTLESTATUS and UPDATEBATTLEINFO commands.
 */
struct CSMyBattleStatusCommand: CSCommand {

    let battleStatus: Battleroom.UserStatus
    let color: Int32

    // MARK: - Manual Construction

    init(battleStatus: Battleroom.UserStatus, color: Int32) {
        self.battleStatus = battleStatus
        self.color = color
    }

    // MARK: - CSCommand

    init?(description: String) {
        guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 2, sentenceCount: 0),
            let statusAsInt = Int(words[0]),
            let battleStatus = Battleroom.UserStatus(statusValue: statusAsInt),
            let color = Int32(words[1]) else {
            return nil
        }
        self.init(battleStatus: battleStatus, color: color)
    }

    func execute(on server: LobbyServer) {
        #warning("Serverside: TODO")
    }

    var description: String {
        return "MYBATTLESTATUS \(battleStatus.integerValue) \(color)"
    }
}

/**
 Notifies a client that their request to JOINBATTLE was successful, and that they have just joined the battle.

 Clients in the battle will be notified of the new user via JOINEDBATTLE.

 Next, the server will send a series of commands to the newly joined client, which might include DISABLEUNITS, ADDBOT, ADDSTARTRECT, SETSCRIPTTAGS and so on, along with multiple CLIENTBATTLESTATUS, in order to describe the current state of the battle to the joining client.

 If the battle has natType>0, the server will also send the clients IP port to the host, via the CLIENTIPPORT command. Someone who knows more about this should write more!
*/
struct SCJoinBattleCommand: SCCommand {
	
	let battleID: Int
	let hashCode: Int32
	
	// MARK: - Manual Construction
	
	init(battleID: Int, hashCode: Int32) {
		self.battleID = battleID
		self.hashCode = hashCode
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 2, sentenceCount: 0),
		let battleID = Int(words[0]),
		let hashCode = Int32(words[1]) else {
			return nil
		}
		
		self.battleID = battleID
		self.hashCode = hashCode
	}
	
	var description: String {
		return "JOINBATTLE \(battleID) \(hashCode)"
	}
	
	func execute(on connection: Connection) {
        guard let myUsername = connection.userAuthenticationController?.username,
            let myID = connection.id(forPlayerNamed: myUsername) else {
            debugOnlyPrint("Error: was instructed to join a battle when not logged in!")
            return
        }
		guard connection.battleController.battleroom == nil else {
			debugOnlyPrint("Was instructed to join a battleroom when already in one!")
            return
		}
		guard let battle = connection.battleList.items[battleID] else {
			debugOnlyPrint("Was instructed to join a battleroom that doesn't exist!")
            return
		}
		
		let battleroomChannel = Channel(title: battle.channel, rootList: battle.userList)
		connection.channelList.addItem(battleroomChannel, with: connection.id(forChannelnamed: battleroomChannel.title))
        let battleroom = Battleroom(battle: battle, channel: battleroomChannel, hashCode: hashCode, resourceManager: connection.resourceManager, battleController: connection.battleController, myID: myID)
        connection.battleController.battleroom = battleroom
		connection.windowController.displayBattleroom(battleroom)
	}
}

/**
 Notifies a client that their request to JOINBATTLE was denied.
*/
struct SCJoinBattleFailedCommand: SCCommand {
	
	let reason: String
	
	// MARK: - Manual Construction
	
	init(reason: String) {
		self.reason = reason
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		self.reason = description
	}
	
	func execute(on connection: Connection) {
		connection.receivedError(.joinBattleFailed(reason: reason))
	}
	
	var description: String {
		return "JOINBATTLEFAILED \(reason)"
	}
}

struct SCClientBattleStatusCommand: SCCommand {
	
	let username: String
	let battleStatus: Battleroom.UserStatus
	let teamColor: Int32
	
	// MARK: - Manual Construction
	
	init(username: String, battleStatus: Battleroom.UserStatus, teamColor: Int32) {
		self.username = username
		self.battleStatus = battleStatus
		self.teamColor = teamColor
	}
	
	// MARK: - SCClientBattleStatusCommand
	
	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 3, sentenceCount: 0),
			let statusAsInt = Int(words[1]),
			let battleStatus = Battleroom.UserStatus(statusValue: statusAsInt),
			let teamColor = Int32(words[2]) else {
			return nil
		}
		self.init(username: words[0], battleStatus: battleStatus, teamColor: teamColor)
	}
	
	func execute(on connection: Connection) {
		guard let battleroom = connection.battleController.battleroom,
			let userID = connection.id(forPlayerNamed: username) else {
			return
		}
        battleroom.setUserStatus(battleStatus, forUserIdentifiedBy: userID)
		battleroom.colors[userID] = teamColor
	}
	
	var description: String {
        return "CLIENTBATTLESTATUS \(username) \(battleStatus.integerValue) \(teamColor)"
	}
}

struct SCRequestBattleStatusCommand: SCCommand {
	
	// MARK: - Manual Construction
	
	init() {}
	
	// MARK: - SCCommand
	
	init?(description: String) {}
	
	func execute(on connection: Connection) {
        guard let battleroom = connection.battleController.battleroom else {
            return
        }
        
        connection.server.send(CSMyBattleStatusCommand(
            battleStatus: battleroom.myBattleStatus,
            color: battleroom.myColor
        ))
	}
	
	var description: String {
		return "REQUESTBATTLESTATUS"
	}
}

struct SCAddBotCommand: SCCommand {
	
	let battleID: Int
	let name: String
	let owner: String
	let battleStatus: Battleroom.UserStatus
	let teamColor: Int32
	let aiDll: String
	
	// MARK: - Manual Construction
	
	init(battleID: Int, name: String, owner: String, battleStatus: Battleroom.UserStatus, teamColor: Int32, aiDll: String) {
		self.battleID = battleID
		self.name = name
		self.owner = owner
		self.battleStatus = battleStatus
		self.teamColor = teamColor
		self.aiDll = aiDll
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, sentences) = try? wordsAndSentences(for: description, wordCount: 5, sentenceCount: 1),
			let battleID = Int(words[0]),
			let statusValue = Int(words[3]),
			let battleStatus = Battleroom.UserStatus(statusValue: statusValue),
			let teamColor = Int32(words[4])
		else {
			return nil
		}
		self.battleID = battleID
		name = words[1]
		owner = words[2]
		self.battleStatus = battleStatus
		self.teamColor = teamColor
		aiDll = sentences[0]
	}
	
	func execute(on connection: Connection) {
		guard let battleroom = connection.battleController.battleroom,
			let ownerID = connection.id(forPlayerNamed: owner),
			let ownerUser = connection.userList.items[ownerID] else {
				return
		}
		let bot = Battleroom.Bot(name: name, owner: ownerUser, status: battleStatus, color: teamColor)
		battleroom.bots.append(bot)
	}
	
	var description: String {
		return "ADDBOT \(battleID) \(name) \(owner) \(battleStatus.integerValue) \(teamColor) \(aiDll)"
	}
}

struct SCRemoveBotCommand: SCCommand {
	
	let botName: String
	
	// MARK: - Manual Construction
	
	init(botName: String) {
		self.botName = botName
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 0) else {
			return nil
		}
		self.botName = words[0]
	}
	
	func execute(on connection: Connection) {
		guard let battleroom = connection.battleController.battleroom else {
			return
		}
		battleroom.bots = battleroom.bots.filter { $0.name != botName }
		
	}
	
	var description: String {
		return "REMOVEBOT \(botName)"
	}
}

struct SCUpdateBotCommand: SCCommand {
	
	let battleID: Int
	let name: String
	let battleStatus: Battleroom.UserStatus
	let teamColor: Int32
	
	// MARK: - Manual Construction
	
	init(battleID: Int, name: String, battleStatus: Battleroom.UserStatus, teamColor: Int32) {
		self.battleID = battleID
		self.name = name
		self.battleStatus = battleStatus
		self.teamColor = teamColor
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 4, sentenceCount: 0),
			let battleID = Int(words[0]),
			let statusValue = Int(words[2]),
			let battleStatus = Battleroom.UserStatus(statusValue: statusValue),
			let teamColor = Int32(words[3]) else {
			return nil
		}
		self.battleID = battleID
		name = words[1]
		self.battleStatus = battleStatus
		self.teamColor = teamColor
	}
	
	func execute(on connection: Connection) {
		guard let battleroom = connection.battleController.battleroom,
			let bot = battleroom.bots.first(where: { $0.name == name }) else {
				return
		}
		
		bot.status = battleStatus
		bot.color = teamColor
	}
	
	var description: String {
		return "UPDATEBOT \(name)"
	}
}

struct SCAddStartRectCommand: SCCommand {
	
	let allyNo: Int
	let left: Int
	let top: Int
	let right: Int
	let bottom: Int
	
	// MARK: - Manual Construction
	
	init(allyNo: Int, left: Int, top: Int, right: Int, bottom: Int) {
		self.allyNo = allyNo
		self.left = left
		self.right = right
		self.top = top
		self.bottom = bottom
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 5, sentenceCount: 0) else {
			return nil
		}
		let integers = words.compactMap { Int($0) }
		guard integers.count == 5 else {
			return nil
		}
		
		allyNo = integers[0]
		left = integers[1]
		top = integers[2]
		right = integers[3]
		bottom = integers[4]
	}
	
	func execute(on connection: Connection) {
        guard let battleroom = connection.battleController.battleroom else {
            return
        }
        let rect = CGRect(x: left, y: top, width: right - left, height: bottom - top)
        battleroom.addStartRect(rect, for: allyNo)
	}
	
	var description: String {
		return "ADDSTARTRECT \(allyNo) \(left) \(top) \(right) \(bottom)"
	}
}

struct SCRemoveStartRectCommand: SCCommand {
	
	let allyNo: Int
	
	// MARK: - Manual Construction
	
	init(allyNo: Int) {
		self.allyNo = allyNo
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 0),
			let allyNo = Int(words[0]) else {
			return nil
		}
		self.allyNo = allyNo
	}
	
	func execute(on connection: Connection) {
        connection.battleController.battleroom?.removeStartRect(for: allyNo)
	}
	
	var description: String {
		return "REMOVESTARTRECT \(allyNo)"
	}
}

struct SCSetScriptTagsCommand: SCCommand {

	let tags: [String]

	// MARK: - Manual Construction

	init(tags: [String]) {
		self.tags = tags
	}

	// MARK: - SCCommand

	init?(description: String) {
		guard let (_, sentences) = try? wordsAndSentences(for: description, wordCount: 0, sentenceCount: 1, optionalSentences: 1000) else {
			return nil
		}
		tags = sentences
	}

	func execute(on connection: Connection) {
		#warning("todo")
	}

	var description: String {
		return "SETSCRIPTTAGS \(tags.joined(separator: "\t"))"
	}
}

struct SCRemoveScriptTagsCommand: SCCommand {

	let keys: [String]

	// MARK: - Manual Construction

	init(keys: [String]) {
		self.keys = keys
	}

	// MARK: - SCCommand

	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 0, optionalWords: 1000) else {
			return nil
		}
		keys = words
	}

	func execute(on connection: Connection) {
		#warning("todo")
	}

	var description: String {
		return "REMOVESCRIPTTAGS \(keys.joined(separator: " "))"
	}
}
struct SCJoinBattleRequestCommand: SCCommand {
	
	let username: String
	let ip: String
	
	// MARK: - Manual Construction
	
	init(username: String, ip: String) {
		self.username = username
		self.ip = ip
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 2, sentenceCount: 0) else {
			return nil
		}
		username = words[0]
		ip = words[1]
	}
	
	func execute(on connection: Connection) {
		#warning("TODO")
	}
	
	var description: String {
		return "JOINBATTLEREQUEST \(username) \(ip)"
	}
}

struct SCJoinedBattleCommand: SCCommand {
	
	let battleID: Int
	let username: String
	let scriptPassword: String?
	
	// MARK: - Manual Construction
	
	init(battleID: Int, username: String, scriptPassword: String?) {
		self.battleID = battleID
		self.username = username
		self.scriptPassword = scriptPassword
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 2, sentenceCount: 0, optionalWords: 1),
			let battleID = Int(words[0]) else {
			return nil
		}
		self.battleID = battleID
		self.username = words[1]
		scriptPassword = words.count == 3 ? words[2] : nil
	}
	
	func execute(on connection: Connection) {
		guard let battle = connection.battleList.items[battleID],
			let userID = connection.id(forPlayerNamed: username) else {
				return
		}
		battle.userList.addItemFromParent(id: userID)
        connection.battleList.respondToUpdatesOnItem(identifiedBy: battleID)
	}
	
	var description: String {
		var string = "JOINEDBATTLE \(battleID) \(username)"
		if let scriptPassword = scriptPassword {
			string += " \(scriptPassword)"
		}
		return string
	}
}

struct SCLeftBattleCommand: SCCommand {
	
	let battleID: Int
	let username: String
	
	// MARK: - Manual Construction
	
	init(battleID: Int, username: String) {
		self.battleID = battleID
		self.username = username
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 2, sentenceCount: 0),
			let battleID = Int(words[0]) else {
			return nil
		}
		self.battleID = battleID
		self.username = words[1]
	}
	
	func execute(on connection: Connection) {
		guard let battle = connection.battleList.items[battleID],
			let userID = connection.id(forPlayerNamed: username) else {
				return
		}
		battle.userList.removeItem(withID: userID)
        connection.battleList.respondToUpdatesOnItem(identifiedBy: battleID)
	}
	
	var description: String {
		return "LEFTBATTLE \(battleID) \(username)"
	}
}

struct SCBattleClosedCommand: SCCommand {
	
	let battleID: Int
	
	// MARK: - Manual Construction
	
	init(battleID: Int) {
		self.battleID = battleID
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 0),
			let battleID = Int(words[1]) else {
			return nil
		}
		self.battleID = battleID
	}
	
	func execute(on connection: Connection) {
		connection.battleList.removeItem(withID: battleID)
	}
	
	var description: String {
		return "BATTLECLOSED \(battleID)"
	}
}

/// Sent as a response to a client's UDP packet (used with "hole punching" NAT traversal technique).
struct SCUDPSourcePortCommand: SCCommand {
	
	let port: Int
	
	// MARK: - Manual Construction
	
	init(port: Int) {
		self.port = port
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 0),
			let port = Int(words[0]) else {
			return nil
		}
		self.port = port
	}
	
	func execute(on connection: Connection) {
		#warning("todo")
	}
	
	var description: String {
		return "UDPSOURCEPORT \(port)"
	}
}

struct SCClientIPPortCommand: SCCommand {
	
	let username: String
	let ip: String
	let port: Int
	
	// MARK: - Manual Construction
	
	init(username: String, ip: String, port: Int) {
		self.username = username
		self.ip = ip
		self.port = port
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 3, sentenceCount: 0),
			let port = Int(words[2]) else {
			return nil
		}
		self.username = words[0]
		self.ip = words[1]
		self.port = port
	}
	
	func execute(on connection: Connection) {
		#warning("todo")
	}
	
	var description: String {
		return "HOSTPORT \(port)"
	}
}



/// Sent by the server to all clients participating in the battle, except for the host, notifying them about the (possibly new) host port.
struct SCHostPortCommand: SCCommand {
	
	let port: Int
	
	// MARK: - Manual Construction
	
	init(port: Int) {
		self.port = port
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 0),
			let port = Int(words[0]) else {
			return nil
		}
		self.port = port
	}
	
	func execute(on connection: Connection) {
		#warning("todo")
	}
	
	var description: String {
		return "HOSTPORT \(port)"
	}
}

/**
 Sent by the server to all registered clients, telling them some of the parameters of the battle changed. A battle's internal changes, like starting metal, energy, starting position etc., are sent only to clients participating in the battle (via the SETSCRIPTTAGS command). 
*/
struct SCUpdateBattleInfoCommand: SCCommand {
	
	let battleID: Int
	let spectatorCount: Int
	let locked: Bool
	let mapHash: Int32
	let mapName: String
	
	// MARK: - Manual Construction
	
	init(battleID: Int, spectatorCount: Int, locked: Bool, mapHash: Int32, mapName: String) {
		self.battleID = battleID
		self.spectatorCount = spectatorCount
		self.mapName = mapName
		self.mapHash = mapHash
		self.locked = locked
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, sentences) = try? wordsAndSentences(for: description, wordCount: 4, sentenceCount: 1),
			let battleID = Int(words[0]),
			let spectatorCount = Int(words[1]),
			let mapHash = Int32(words[3]) else {
			return nil
		}
		self.battleID = battleID
		self.spectatorCount = spectatorCount
		locked = words[2] == "1"
		self.mapHash = mapHash
		mapName = sentences[0]
	}
	
	func execute(on connection: Connection) {
		guard let battle = connection.battleList.items[battleID] else {
			return
		}
		battle.spectatorCount = spectatorCount
		battle.isLocked = locked
		battle.map = Battle.Map(name: mapName, hash: mapHash)
        connection.battleList.respondToUpdatesOnItem(identifiedBy: battleID)
	}
	
	var description: String {
		return "UPDATEBATTLEINFO \(battleID) \(spectatorCount) \(locked ? 1 : 0) \(mapHash) \(mapName)"
	}
}

/// Sent by the server to notify the battle host that the named user should be kicked from the battle in progress.
struct SCKickFromBattleCommand: SCCommand {
	
	let battleID: Int
	let username: String
	
	// MARK: - Manual Construction
	
	init(battleID: Int, username: String) {
		self.battleID = battleID
		self.username = username
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 2, sentenceCount: 0),
			let battleID = Int(words[0]) else {
			return nil
		}
		self.battleID = battleID
		username = words[1]
	}
	
	func execute(on connection: Connection) {
		#warning("todo")
	}
	
	var description: String {
		return "KICKFROMBATTLE \(battleID) \(username)"
	}
}

/**
Sent to a client that was kicked from their current battle by the battle founder.

The client does not need to send LEAVEBATTLE, as removal has already been done by the server. The only purpose of this command is to notify the client that they were kicked. (The client will also recieve a corresponding LEFTBATTLE notification.)
*/
struct SCForceQuitBattleCommand: SCCommand {
	
	// MARK: - Manual Construction
	
	init() {}
	
	// MARK: - SCCommand
	
	init?(description: String) {}
	
	func execute(on connection: Connection) {
		connection.battleController.battleroom = nil
	}
	
	var description: String {
		return "FORCEQUITBATTLE"
	}
}

/**
Sent by the server to all clients in a battle, telling them that some units have been added to disabled units list. Also see the DISABLEUNITS command.
*/
struct SCDisableUnitsCommand: SCCommand {
	
	let units: [String]
	
	// MARK: - Manual Construction
	
	init(units: [String]) {
		self.units = units
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 0, optionalWords: 1000) else {
			return nil
		}
		units = words
	}
	
	func execute(on connection: Connection) {
		connection.battleController.battleroom?.disabledUnits.append(contentsOf: units)
	}
	
	var description: String {
		return "DISABLEUNITS \(units.joined(separator: " "))"
	}
}

/**
Sent by the server to all clients in a battle, telling them that some units have been added to enabled units list. Also see the DISABLEUNITS command.
*/
struct SCEnableUnitsCommand: SCCommand {
	
	let units: [String]
	
	// MARK: - Manual Construction
	
	init(units: [String]) {
		self.units = units
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		guard let (words, _) = try? wordsAndSentences(for: description, wordCount: 1, sentenceCount: 0, optionalWords: 1000) else {
			return nil
		}
		units = words
	}
	
	func execute(on connection: Connection) {
		connection.battleController.battleroom?.disabledUnits.removeAll(where: { units.contains($0) })
	}
	
	var description: String {
		return "ENABLEUNITS \(units.joined(separator: " "))"
	}
}
/**
Sent to notify a client that another user requested that a "ring" sound be played to them.
*/
struct SCRingCommand: SCCommand {
	
	let username: String
	
	// MARK: - Manual Construction
	
	init(username: String) {
		self.username = username
	}
	
	// MARK: - SCCommand
	
	init?(description: String) {
		username = description
	}
	
	func execute(on connection: Connection) {
		#warning("todo")
	}
	
	var description: String {
		return "RING \(username)"
	}
}

