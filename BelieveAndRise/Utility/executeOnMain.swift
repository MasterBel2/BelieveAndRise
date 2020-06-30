//
//  File.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 12/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/// Asynchronously executes on the main thread, unless already on the main thread.
func executeOnMain<T: AnyObject>(target: Optional<T>, _ block: @escaping (T) -> Void) {
    if let target = target {
        executeOnMain(target: target, block)
    }
}

/// Asynchronously executes on the main thread, unless already on the main thread.
func executeOnMain<T: AnyObject>(target: T, _ block: @escaping (T) -> Void) {
    if Thread.isMainThread {
        block(target)
    } else {
        DispatchQueue.main.async { [weak target] in
            if let target = target {
                block(target)
            }
        }
    }
}


/// Asynchronously executes on the main thread, unless already on the main thread.
func executeOnMain(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async {
            block()
        }
    }
}
