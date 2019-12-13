//
//  TableHeaderData.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 25/6/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

struct TableHeaderData {
	let title: String
	let option: Option
	
	struct Option {
		let title: String
		let action: () -> Void
	}
}
