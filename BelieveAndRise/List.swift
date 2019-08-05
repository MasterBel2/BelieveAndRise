//
//  List.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 16/7/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

protocol ListDelegate: AnyObject {
	
}

protocol ListDataSource: AnyObject {
	
}

struct List {
	private(set) var itemIDs: [Int] = []
	
	private var itemCount: Int {
		return itemIDs.count
	}
	
	weak var delegate: ListDelegate?
	weak var dataSource: ListDataSource?
	
	mutating func addItem(withID id: Int) {
		itemIDs.append(id)
	}
	
	mutating func removeItem(withID id: Int) {
		itemIDs = itemIDs.filter { $0 != id }
	}
	
	func itemID(at index: Int) -> Int? {
		return itemIDs[index]
	}
}
