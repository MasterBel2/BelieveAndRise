//
//  ImageType.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 25/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

typealias ImageType = NSImage

#warning("force downcast will always fail for StaticString")
extension IconLoading where Self: StringProtocol {
	var image: ImageType {
		return ImageType(named: self as! NSImage.Name)!
	}
}
