//
//  NSView+BackgroundColor.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 10/12/16.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

class ColoredView: NSView {
    var backgroundColor: NSColor? {
        didSet {
            wantsLayer = backgroundColor != nil
            setNeedsDisplay(bounds)
        }
    }

    override var wantsUpdateLayer: Bool {
        return backgroundColor != nil
    }

    override func updateLayer() {
        super.updateLayer()
        layer?.backgroundColor = backgroundColor?.cgColor
    }
}
