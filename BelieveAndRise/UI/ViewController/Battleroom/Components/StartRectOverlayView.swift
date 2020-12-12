//
//  StartRectOverlayView.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 13/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

final class StartRectOverlayView: ColoredView, NibLoadable {
	@IBOutlet weak var allyTeamNumberLabel: NSTextField!

    private var unscaledRect: CGRect = .zero

    static func loadForAllyTeam(_ allyTeam: Int, unscaledRect: CGRect, mapRect: CGRect) -> StartRectOverlayView {
        let startRectView = StartRectOverlayView.loadFromNib()
        startRectView.unscaledRect = unscaledRect
        startRectView.adjustFrame(for: mapRect)
        startRectView.allyTeamNumberLabel.stringValue = String(allyTeam)
        startRectView.backgroundColor = NSColor.white.withAlphaComponent(0.3)
        startRectView.adjustFrame(for: mapRect)
        return startRectView
    }

    func adjustFrame(for mapRect: CGRect) {
        let x = unscaledRect.minX / 200 * mapRect.width
        let y = unscaledRect.minY / 200 * mapRect.height
        let width = unscaledRect.width / 200 * mapRect.width
        let height = unscaledRect.height / 200 * mapRect.height

        frame = CGRect(x: x + mapRect.minX, y: y + mapRect.minY, width: width, height: height)
    }
}
