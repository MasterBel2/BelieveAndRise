//
//  BattleroomViewController.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 13/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

class BattleroomViewController: NSViewController, BattleroomDelegate {

    // MARK: - Outlets

    @IBOutlet var stackView: NSStackView!
    @IBOutlet weak var infoView: BattleroomInfoView!
	@IBOutlet weak var minimapView: MinimapView!

    // MARK: - Data

    var battleroom: Battleroom!

    // MARK: - Lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()

        let spectatorListViewController = ListViewController()
        let allyTeamListViewController = ListViewController()

        battleroom.allyTeamListDisplay = allyTeamListViewController
        battleroom.spectatorListDisplay = spectatorListViewController

        spectatorListViewController.itemViewProvider = DefaultPlayerListItemViewProvider(list: battleroom.battle.userList)
        allyTeamListViewController.itemViewProvider = DefaultPlayerListItemViewProvider(list: battleroom.battle.userList)

        addChild(spectatorListViewController)
        stackView.addArrangedSubview(spectatorListViewController.view)
		addChild(allyTeamListViewController)
		stackView.addArrangedSubview(allyTeamListViewController.view)
		
		spectatorListViewController.view.widthAnchor.constraint(equalTo: allyTeamListViewController.view.widthAnchor).isActive = true
    }

    // MARK: - Battleroom Delegate

}

final class BattleroomInfoView: NSView {
	
}

final class MinimapView: NSImageView {
	var startRects: [Int : NSView] = [:]
	
	private var map: Map? {
		didSet {
			guard let map = map,
				let mapRect = mapRect
				else {
				return
			}
			map.image.size = mapRect.size
			startRects = [:]
			image = map.image
		}
	}
	
	var mapRect: CGRect? {
		guard let map = map else {
			return nil
		}
		
		let widthFactor = bounds.width / map.width
		let heightFactor = bounds.height / map.height
		let factor = widthFactor < heightFactor ? widthFactor : heightFactor
		
		let width = map.width * factor
		let height = map.height * factor
		let x = (bounds.width - width) / 2
		let y = (bounds.height - height) / 2
		
		return CGRect(x: x, y: y, width: width, height: height)
	}
	
	func addStartRect(_ rect: CGRect, for allyTeam: Int) {
		guard let mapRect = mapRect else {
			return
		}
		let x = rect.minX / 200 * mapRect.width
		let y = rect.minY / 200 * mapRect.height
		let width = rect.width / 200 * mapRect.width
		let height = rect.height / 200 * mapRect.height
		let newRect = CGRect(x: x + mapRect.minX, y: y + mapRect.minY, width: width, height: height)
		
		let view = StartRectOverlayView.loadFromNib()
		view.frame = newRect
		view.allyTeamNumberLabel.stringValue = String(allyTeam)
		view.backgroundColor = NSColor(deviceRed: 1, green: 1, blue: 1, alpha: 1)
	}
	
	struct Map {
		let image: NSImage
		let width: CGFloat
		let height: CGFloat
	}
}
