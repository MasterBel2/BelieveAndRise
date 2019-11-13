//
//  ServerError.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 14/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

enum ServerError {
    case joinFailed(channel: String, reason: String)
    case joinBattleFailed(reason: String)
    case resetPasswordDenied(errorMessage: String)
    case resetPasswordRequestDenied(errorMessage: String)
    case resendVerificationDenied(errorMessage: String)
    case changeEmailDenied(errorMessage: String)
    case changeEmailRequestDenied(errorMessage: String)
    case registrationDenied(reason: String)
    case loginDenied(reason: String)
    /// A command sent to the server has either failed, been denied, or otherwise cannot be completed.
    /// This normally is used as a generic error command, to inform lobby/client developers that they have not used the protocol correctly.
    case failed
    case openBattleFailed(reason: String)
}
