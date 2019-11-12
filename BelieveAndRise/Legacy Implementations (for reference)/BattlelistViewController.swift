//
//  BattlelistViewController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 13/9/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Foundation

//class BattleListViewController: ListViewController {
//
//}
//
//class SomethingListViewController<ListItem: Sortable>: ListViewController {
//    func setList(_ list: List<ListItem>, sectionKey: ListItem.PropertyKey, sortKey: ListItem.PropertyKey) {
//        // Status: Section key should not stay
//        let inBattle = List<ListItem>(title: "In Battle", sortKey: sortKey, parent: list)
//        list.items.keys.forEach(inBattle.addItemFromParent(id:))
//
//        let inGame = List<ListItem>(title: "In Game", sortKey: sortKey, parent: list)
//        list.items.keys.forEach(inGame.addItemFromParent(id:))
//
//        let online = List<ListItem>(title: "Online", sortKey: sortKey, parent: list)
//        list.items.keys.forEach(online.addItemFromParent(id:))
//
//        let away = List<ListItem>(title: "Away", sortKey: sortKey, parent: list)
//        list.items.keys.forEach(away.addItemFromParent(id:))
//
////        setTableSections([inBattle, inGame, online, away].map(listTableSection(for:)))
//    }
//
//    private func listTableSection(for list: List<ListItem>) -> ListTableSection {
//        return ListTableSection(
//            title: list.title,
//            entries: list.items.values.map(listTableEntry(for:))
//        )
//    }
//
//    private func listTableEntry(for listItem: ListItem) -> ListTableEntry {
//        return ListTableEntry(
//            primaryTitle: "Primary",
//            secondaryTitle: "Secondary"
//        )
//    }
//
//    func list(_ list: List<ListItem>, didAddItemAt index: Int) {
////        <#code#>
//    }
//
//    func list(_ list: List<ListItem>, didRemoveItemAt index: Int) {
////        <#code#>
//    }
//}
