//
//  File.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 12/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/// Synchronously executes on the main thread.
func executeOnMain<T: AnyObject, Result>(target: T, block: (T) -> Result) -> Result {
    if Thread.isMainThread {
        return block(target)
    } else {
        return DispatchQueue.main.sync {
            return block(target)
        }
    }
}

/// Synchronously executes on the main thread.
func executeOnMain<Result>(block: () -> Result) -> Result {
    if Thread.isMainThread {
        return block()
    } else {
        return DispatchQueue.main.sync {
            return block()
        }
    }
}
