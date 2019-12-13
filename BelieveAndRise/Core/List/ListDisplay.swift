//
//  ListDisplay.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 26/8/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

protocol ListDisplay: AnyObject {
    func addSection(_ list: ListProtocol)
    func removeSection(_ list: ListProtocol)
	var itemViewProvider: ItemViewProvider { get set }
	var selectionHandler: ListSelectionHandler? { get set }
}
