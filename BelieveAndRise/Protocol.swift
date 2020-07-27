//
//  Protocol.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 4/7/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

// https://springrts.com/dl/LobbyProtocol/ProtocolDescription.html

/// Describes whether certain features are supported by the current protocol.
struct ProtocolFeatureAvailability {
    let serverProtocol: CommandHandler.ServerProtocol

    var requiresVerificationCodeForChangeEmail: Bool {
        switch serverProtocol {
        case .tasServer(let version):
            return ProtocolFeature.TASServer.emailVerification.isAvailable(in: version)
        default:
            return false
        }
    }
}

/// Indicates for which version of which protocols a given feature is available.
struct ProtocolFeature {

    let protocolName: String
    let firstVersion: Float?
    let lastVersion: Float?

    func isAvailable(in version: Float) -> Bool {
        return ((firstVersion ?? -Float.infinity)...(lastVersion ?? Float.infinity)).contains(version)
    }

    private init(protocolName: String, versions: ClosedRange<Float>) {
        self.protocolName = protocolName
        firstVersion = versions.lowerBound
        lastVersion = versions.upperBound
    }
    private init(protocolName: String, addedIn version: Float) {
        self.protocolName = protocolName
        firstVersion = version
        lastVersion = nil
    }
    private init(protocolName: String, removedAfter version: Float) {
        self.protocolName = protocolName
        firstVersion = nil
        lastVersion = version
    }
    private init(protocolName: String, version: Float) {
        self.protocolName = protocolName
        firstVersion = version
        lastVersion = nil
    }

    enum TASServer {

        // MARK: - TASServer Pre-0.36 (Removed in current)

        /// Associated with the RequestUpdateFile and OfferFile commands.
        static let fileHandling = ProtocolFeature(protocolName: "TASServer", removedAfter: 0.35)
        /// Associated with the UserID, GenerateUserID, and AcquireUserID commands.
        static let userID = ProtocolFeature(protocolName: "TASServer", removedAfter: 0.35)
        /// Associated with the ForgeReverseMessage command.
        static let forgeReverseMessage = ProtocolFeature(protocolName: "TASServer", removedAfter: 0.35)

        // MARK: - TASServer 0.36
        // This section will describe some features never implemented by this client, but are documented here for completeness.

        /// Adds `scriptPassword` argument to the `CSJoinBattle` and `SCJoinedBattle` commands.
        static let scriptPassword = ProtocolFeature(protocolName: "TASServer", addedIn: 0.36)
        /// Adds the `CSListCompFlags` and `SCCompFlags` commands.
        static let listCompFlags = ProtocolFeature(protocolName: "TASServer", addedIn: 0.36)
        /// Adds the  `CSChangeEmail` client command. Modified in 0.38.
        static let changeEmail = ProtocolFeature(protocolName: "TASServer", addedIn: 0.36)
        /// The optional `CSExit` command allowing a client to specify a reason for disconnect.
        static let exit = ProtocolFeature(protocolName: "TASServer", addedIn: 0.36)

        // MARK: Removed for 0.38

        /// Adds the `CSGetIngameTime` client command
        static let getIngameTime = ProtocolFeature(protocolName: "TASServer", versions: 0.36...0.37)

        // MARK: - TASServer 0.37

        /// Adds the Ignore command set.
        static let ignoreCommandSet = ProtocolFeature(protocolName: "TASServer", addedIn: 0.37)

        // MARK: Removed for 0.38

        /// Adds the ForceJoinBattle command set.
        static let forceJoinBattle = ProtocolFeature(protocolName: "TASServer", removedAfter: 0.37)
        /// Adds the ConnectUser command set.
        static let connectUser = ProtocolFeature(protocolName: "TASServer", removedAfter: 0.37)
        /// Adds the JoinBattleRequest command set (for hosts).
        static let joinBattleRequest = ProtocolFeature(protocolName: "TASServer", removedAfter: 0.37)

        // MARK: Only in this version

        /// Adds the NoChannelTopic command
        static let noChannelTopic = ProtocolFeature(protocolName: "TASServer", version: 0.37)
        /// Adds a set of crypto commands.
        static let crypto0_37 = ProtocolFeature(protocolName: "TASServer", version: 0.37)
        /// Adds the SayData command set.
        static let sayData = ProtocolFeature(protocolName: "TASServer", version: 0.37)

        // MARK: - TASServer 0.38

        /// Adds a new interface for bridge bots.
        static let bridgeInterface = ProtocolFeature(protocolName: "TASServer", addedIn: 0.38)
        /// Represented by the "u" compatability flag.
        static let channelBattleMerge = ProtocolFeature(protocolName: "TASServer", addedIn: 0.38)
        /// Adds the TLS command set.
        static let crypto0_38 = ProtocolFeature(protocolName: "TASServer", addedIn: 0.38)
        /**
         Describes the email verification command set. When email verification is enabled:
         - Register requires an `email` argument
         - ConfirmAgreement requires a `verificationCode` argument
         - ChangeEmail requires a `verificationCode` argument
         - ResetPassword requires a `verificationCode` argument
         */
        static let emailVerification = ProtocolFeature(protocolName: "TASServer", addedIn: 0.38)
    }
}
