//
//  DynamicLibraryHandle.swift
//  OSXSpringLobby
//
//  Created by Belmakor on 10/12/16.
//  Copyright © 2016 MasterBel2. All rights reserved.
//

import Foundation

/// A handle providing access to a library.
final class DynamicLibraryHandle {

    private let handle: UnsafeMutableRawPointer

    init?(libraryPath: String) {
        guard let handle = dlopen(libraryPath, RTLD_LAZY + RTLD_LOCAL) else {
            return nil
        }
        self.handle = handle
    }

    deinit {
        dlclose(handle)
    }

    /// Resolves a function without checking for failure.
    func unsafeResolve<T>(_ functionName: String) -> T {
        return resolve(functionName)!
    }
    
    /// Resolves a function from the library, returning nil on failure.
    func resolve<T>(_ functionName: String) -> T? {
        let sym = dlsym(handle, functionName)
        let value = unsafeBitCast(sym, to: T.self)
        return value
    }
}
