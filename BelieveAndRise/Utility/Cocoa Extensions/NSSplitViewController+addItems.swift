//
//  NSSplitViewController+addItems.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 7/2/21.
//  Copyright © 2021 MasterBel2. All rights reserved.
//

import Cocoa

extension NSSplitViewController {
	/// Adds an NSSplitViewItem for each of the supplied view controllers, in the order they appear in the array.
	func addItems(forViewControllers viewControllers: [NSViewController]) {
		viewControllers.forEach({ addSplitViewItem(NSSplitViewItem(viewController: $0)) })
	}
}
