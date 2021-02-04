//
//  StartRectOverlayView.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 13/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa
import UberserverClientCore

final class StartRectOverlayView: ColoredView, NibLoadable {
	@IBOutlet weak var allyTeamNumberLabel: NSTextField!

    private var unscaledRect: StartRect!

    static func loadForAllyTeam(_ allyTeam: Int, unscaledRect: StartRect, mapRect: CGRect) -> StartRectOverlayView {
        let startRectView = StartRectOverlayView.loadFromNib()
		startRectView.unscaledRect = unscaledRect
        startRectView.adjustFrame(for: mapRect)
        startRectView.allyTeamNumberLabel.stringValue = String(allyTeam)
        startRectView.backgroundColor = NSColor.white.withAlphaComponent(0.3)
        startRectView.adjustFrame(for: mapRect)
        return startRectView
    }

    func adjustFrame(for mapRect: CGRect) {
		let something: (x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) = unscaledRect.scaled()
        let x = something.x * mapRect.width
        let y = something.y * mapRect.height
        let width = something.width * mapRect.width
        let height = something.height * mapRect.height

        frame = CGRect(x: x + mapRect.minX, y: y + mapRect.minY, width: width, height: height)
    }
}
