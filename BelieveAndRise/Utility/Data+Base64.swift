//
//  NSData+Base64.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 25/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

extension Data {
	func base64Encoded() -> String {
		return base64EncodedString(options: [])
	}
}
