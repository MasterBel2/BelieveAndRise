//
//  MinimapView.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 14/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

protocol MinimapDisplay: AnyObject {
    func addStartRect(_ rect: CGRect, for allyTeam: Int)
    func removeStartRect(for allyTeam: Int)
    func displayMapUnknown()
    func displayMap(_ imageData: [UInt16], dimension: Int, realWidth: Int, realHeight: Int)
}

final class MinimapView: NSImageView, MinimapDisplay {

    // MARK: - View Components

    private(set) var startRects: [Int : NSView] = [:]

    // MARK: - Properties

    /// Must be set after the mapRect
    private var map: Map? {
        didSet {
            guard let map = map else {
                image = nil
                return
            }
            map.image.size = mapRect(for: map).size
            startRects = [:]
            image = map.image
        }
    }

    /// Calculates a rect ot
    private func mapRect(for map: Map) -> CGRect {
        let widthFactor = bounds.width / map.width
        let heightFactor = bounds.height / map.height
        let factor = widthFactor < heightFactor ? widthFactor : heightFactor

        let width = map.width * factor
        let height = map.height * factor
        let x = (bounds.width - width) / 2
        let y = (bounds.height - height) / 2

        return CGRect(x: x, y: y, width: width, height: height)
    }

    // MARK: - MinimapDisplay

    func addStartRect(_ rect: CGRect, for allyTeam: Int) {
        executeOnMain(target: self) {
            $0._addStartRect(rect, for: allyTeam)
        }
    }

    func _addStartRect(_ rect: CGRect, for allyTeam: Int) {
        guard let map = map else {
            return
        }

        let mapRect = self.mapRect(for: map)
        let x = rect.minX / 200 * mapRect.width
        let y = rect.minY / 200 * mapRect.height
        let width = rect.width / 200 * mapRect.width
        let height = rect.height / 200 * mapRect.height
        let newRect = CGRect(x: x + mapRect.minX, y: y + mapRect.minY, width: width, height: height)

        let view = StartRectOverlayView.loadFromNib()
        view.frame = newRect
        view.allyTeamNumberLabel.stringValue = String(allyTeam)
        view.backgroundColor = NSColor(deviceRed: 1, green: 1, blue: 1, alpha: 0.3)
        startRects[allyTeam] = view
        addSubview(view)
    }

    func removeStartRect(for allyTeam: Int) {
        executeOnMain(target: self) {
            if let view = $0.startRects[allyTeam] {
                view.removeFromSuperview()
                $0.startRects[allyTeam] = nil
            }
        }
    }

    func displayMapUnknown() {
        executeOnMain(target: self) {
            $0.map = nil
        }
    }

    func displayMap(_ imageData: [UInt16], dimension: Int, realWidth: Int, realHeight: Int) {
        executeOnMain(target: self) {
            guard let image = NSImage(rgb565Pixels: imageData, width: dimension, height: dimension) else {
                $0.displayMapUnknown()
                return
            }
            let map = Map(image: image, width: CGFloat(realWidth), height: CGFloat(realHeight))
            $0.map = map
        }
    }

    // MARK: - Associated types

    struct Map {
        let image: NSImage
        let width: CGFloat
        let height: CGFloat
    }
}
