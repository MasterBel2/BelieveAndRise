//
//  NibLoadable.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 25/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

protocol NibLoadable {
	static var nibName: String { get }
	static func loadFromNib(in bundle: Bundle) -> Self
    /// Called after the view was loaded from a Nib.
    ///
    /// Override this method to perform post-initialisation setup to a view that has been loaded
    /// from a Nib.
    func loadedFromNib()
}

extension NibLoadable where Self: NSView {
	
	static var nibName: String {
		return String(describing: Self.self)
	}
	
	static func loadFromNib(in bundle: Bundle = Bundle.main) -> Self {
		var topLevelArray: NSArray? = nil
		bundle.loadNibNamed(NSNib.Name(nibName), owner: self, topLevelObjects: &topLevelArray)
		let view = (Array<Any>(topLevelArray!).filter { $0 is Self }).last as! Self
        view.identifier = NSUserInterfaceItemIdentifier(nibName)
        view.loadedFromNib()
		return view
	}

    func loadedFromNib() {}
}
