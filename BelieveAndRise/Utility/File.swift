//
//  File.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 12/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

struct IncompleteAuthenticateUserRequest {
    let username: String?
    let password: String?
    let email: String?

    static var empty: IncompleteAuthenticateUserRequest {
        return IncompleteAuthenticateUserRequest(username: nil, password: nil, email: nil)
    }
}

func executeOnMain<T: AnyObject>(target: T, block: (T) -> Void) {
    if Thread.isMainThread {
        block(target)
    } else {
        DispatchQueue.main.sync {
            block(target)
        }
    }
}

func debugOnlyPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    print(items, separator: separator, terminator: terminator)
    #endif
}
