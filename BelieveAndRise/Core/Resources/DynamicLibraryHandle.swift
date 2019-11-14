//
//  DynamicLibraryHandle.swift
//  OSXSpringLobby
//
//  Created by Belmakor on 10/12/16.
//  Copyright © 2016 MasterBel2. All rights reserved.
//

import Foundation

class DynamicLibraryHandle {

    private let handle: UnsafeMutableRawPointer

    init?(libraryPath: String) {
        guard let handle = dlopen(libraryPath, RTLD_LAZY + RTLD_LOCAL) else {
//            NSLog("Failed to load library at: \(libraryPath)")
            return nil
        }
        self.handle = handle
    }

    deinit {
        dlclose(handle)
    }

    func resolve<T>(_ functionName: String, _ type: T.Type) -> T? {
        let sym = dlsym(handle, functionName)
        let value = unsafeBitCast(sym, to: type)
        return value
    }
}
