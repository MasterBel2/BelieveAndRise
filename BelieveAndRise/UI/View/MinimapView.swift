//
//  MinimapView.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 14/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa

protocol MinimapDisplay: AnyObject {
    /// Draws a start rect overlay on the minimap for the specified allyteam.
    func addStartRect(_ rect: CGRect, for allyTeam: Int)
    /// Removes the start rect coresponding to the specified ally team.
    func removeStartRect(for allyTeam: Int)
    /// Removes all start rects that have been displayed.
    func removeAllStartRects()

    /// Displays an image in place of the map, indicating the minimap cannot be loaded for the specified map (likely because the map
    /// has not yet been downloaded).
    func displayMapUnknown()
    /// Displays a minimap with the given image dimension, and the given map dimensions.
    func displayMap(_ imageData: [UInt16], dimension: Int, realWidth: Int, realHeight: Int)
}

final class MinimapView: NSImageView, MinimapDisplay {

    // MARK: - View Components

    private var startRects: [Int : NSView] = [:]

    // MARK: - Properties

    /// The map to be displayed.
	///
    /// Must be set after the mapRect.
    private var map: Map? {
        didSet {
            guard let map = map else {
                image = nil
                return
            }
            map.image.size = mapRect(for: map).size
            image = map.image
        }
    }

    /// Calculates a CGRect describing the maximum size and its corresponding inset such that the map will be displayed within the bounds of and centred relative to the minimap view.
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
        executeOnMain { [weak self] in
            self?._addStartRect(rect, for: allyTeam)
        }
    }

    private func _addStartRect(_ rect: CGRect, for allyTeam: Int) {
        guard let map = map else {
            return
        }

        if startRects[allyTeam] != nil {
            removeStartRect(for: allyTeam)
        }

        let mapRect = self.mapRect(for: map)
        // Rescale start rect to the map rect.
        let x = rect.minX / 200 * mapRect.width
        let y = rect.minY / 200 * mapRect.height
        let width = rect.width / 200 * mapRect.width
        let height = rect.height / 200 * mapRect.height

        // Position the start rect relative to the map rect.
        let newRect = CGRect(x: x + mapRect.minX, y: y + mapRect.minY, width: width, height: height)

        let view = StartRectOverlayView.loadFromNib()
        view.frame = newRect
        view.allyTeamNumberLabel.stringValue = String(allyTeam)
        view.backgroundColor = NSColor(deviceRed: 1, green: 1, blue: 1, alpha: 0.3)
        startRects[allyTeam] = view
        addSubview(view)
    }

    func removeStartRect(for allyTeam: Int) {
        executeOnMain(target: self) { _self in
            if let view = _self.startRects[allyTeam] {
                view.removeFromSuperview()
                _self.startRects[allyTeam] = nil
            }
        }
    }

    func removeAllStartRects() {
        executeOnMain(target: self) { _self in
            for (key, value) in _self.startRects {
                value.removeFromSuperview()
                _self.startRects[key] = nil
            }
        }
    }

    func displayMapUnknown() {
        executeOnMain(target: self) { _self in
            _self.map = nil
            _self.image = #imageLiteral(resourceName: "Caution")
        }
    }

    /// Converts image data into an image and displays a new map with the given aspect ratio. If image generation fails, the view
    /// assumes a "map unknown" state
    func displayMap(_ imageData: [UInt16], dimension: Int, realWidth: Int, realHeight: Int) {
        executeOnMain { [weak self] in
            self?._displayMap(imageData, dimension: dimension, realWidth: realWidth, realHeight: realHeight)
        }
        
    }
    private func _displayMap(_ imageData: [UInt16], dimension: Int, realWidth: Int, realHeight: Int) {
        guard let image = NSImage(rgb565Pixels: imageData, width: dimension, height: dimension) else {
            displayMapUnknown()
            return
        }
        let map = Map(image: image, width: CGFloat(realWidth), height: CGFloat(realHeight))
        self.map = map
    }

    // MARK: - Associated types

    struct Map {
        let image: NSImage
        let width: CGFloat
        let height: CGFloat
    }
}
