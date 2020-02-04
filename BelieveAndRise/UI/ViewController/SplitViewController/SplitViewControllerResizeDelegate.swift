//
//  SplitViewControllerResizeDelegate.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 3/2/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa

/// A set of delegate methods associated with split view controller resize events.
protocol SplitViewControllerResizeDelegate {
    /// Notifies the delegate of a change in the width of an NSSplitViewController's split view item.
    func splitViewController(_ splitViewController: NSSplitViewController, viewWasResizedFor viewController: NSViewController)
}
