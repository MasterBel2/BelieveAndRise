//
//  NSView+BackgroundColor.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 10/12/16.
//  Copyright © 2016 MasterBel2. All rights reserved.
//

import Cocoa

extension NSView {
    
    var backgroundColor: NSColor? {
        get {
            guard let cgColor = layer?.backgroundColor else { return nil }
            return NSColor(cgColor: cgColor)
        }
        set {
            wantsLayer = true
            layer?.backgroundColor = newValue?.cgColor
        }
    }
}
