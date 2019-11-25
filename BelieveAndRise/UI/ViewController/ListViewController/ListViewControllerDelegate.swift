//
//  ListViewControllerDelegate.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 4/7/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/// A set of methods that allow a delegate to extend the functionality of a
/// list view controller
protocol ListViewControllerDelegate: AnyObject {
	/// Notifies the delegate that the item was selected.
	func selectedItem(at indexPath: IndexPath)
}
