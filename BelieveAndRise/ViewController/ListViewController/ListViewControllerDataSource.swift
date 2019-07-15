//
//  ListViewControllerDataSource.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 4/7/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

/// A set of methods that a list view controller uses to provide data to a list view
/// controller and to allow the editing of the list view controller's data source object.
protocol ListViewControllerDataSource: AnyObject {
	/// Returns a prepared view controller corresponding to the item at the given index.
	///
	/// When an item in the list view controller is selected, the list view controller
	/// first notifies its delegate that the selection has occurred, and the delegate
	/// should do any necessary preparation. Immideately after, the list view controller
	/// requests the view controller corresponding to the item in its list and presents
	/// it. If the data is being fetched asynchronously, the view controller should be
	/// prepared in a loading state and should update itself when the data arrives.
	func listViewController(_ listViewController: ListViewController, viewControllerForItemAt indexPath: IndexPath)
}
