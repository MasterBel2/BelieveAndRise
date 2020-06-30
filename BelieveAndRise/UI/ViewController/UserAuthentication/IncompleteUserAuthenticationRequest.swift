//
//  IncompleteUserAuthenticationRequest.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 30/6/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation
@available(*, deprecated, message: "Please find a less wacky solution.")
struct IncompleteAuthenticateUserRequest {
    let username: String?
    let password: String?
    let email: String?

    static var empty: IncompleteAuthenticateUserRequest {
        return IncompleteAuthenticateUserRequest(username: nil, password: nil, email: nil)
    }
}
