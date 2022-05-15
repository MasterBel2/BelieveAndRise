//
//  ChatLogViewController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 25/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa
import UberserverClientCore

final class ChatLogViewController: ListViewController {
    override func addSection(_ list: ListProtocol) {
        executeOnMainSync {
            self._addSection(list)
        }
    }

    private func _addSection(_ list: ListProtocol) {
        guard isViewLoaded else {
            return
        }
        super.addSection(list)
        tableView.scrollRowToVisible(tableView.numberOfRows - 1)
    }

    override func list(_ list: ListProtocol, didAddItemWithID id: Int, at index: Int) {
        executeOnMainSync {
            self._list(list, didAddItemWithID: id, at: index)
        }
    }

    private func _list(_ list: ListProtocol, didAddItemWithID id: Int, at index: Int) {
        guard isViewLoaded else {
            return
        }
        super.list(list, didAddItemWithID: id, at: index)
        tableView.scrollRowToVisible(tableView.numberOfRows - 1)
    }
}
