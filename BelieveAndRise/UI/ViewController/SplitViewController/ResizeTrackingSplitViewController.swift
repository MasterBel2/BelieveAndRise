//
//  ResizeTrackingSplitViewController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 3/2/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Cocoa

/// A subclass of NSSplitViewController that provides a delegate property that may respond to reszing split view items.
final class ResizeTrackingSplitViewController: NSSplitViewController {

    /// A delegate that will be notified of changes in the width of an associated NSSplitViewItem.
    var resizeDelegate: SplitViewControllerResizeDelegate?

    override func splitViewDidResizeSubviews(_ notification: Notification) {
        super.splitViewDidResizeSubviews(notification)

        // Notify the resize delegates that the split views were resized.

        splitViewItems.forEach({
            resizeDelegate?.splitViewController(self, viewWasResizedFor: $0.viewController)
        })
    }
}
