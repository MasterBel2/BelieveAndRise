//
//  NSView+addBacking.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 1/8/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa

extension NSView {
    func addBacking(_ color: NSColor = .white) {
        let backing = ColoredView(frame: bounds)
        backing.translatesAutoresizingMaskIntoConstraints = false
        subviews.insert(backing, at: 0)
        backing.backgroundColor = color
        backing.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        backing.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backing.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        backing.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
