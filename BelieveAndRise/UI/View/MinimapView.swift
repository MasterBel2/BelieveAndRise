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

    /// Prepares the view with the given map dimensions. Must be set before `displayMapImage(for:dimension:)` is called.
    func setMapDimensions(_ width: Int, _ height: Int)
    /// Displays a minimap with the given image dimension. Must be called after  `setMapDimensions(_:_:)`.
    func displayMapImage(for imageData: [RGB565Color], dimension: Int)
}

final class MinimapView: NSImageView, MinimapDisplay {

    // MARK: - View Components

    private var startRects: [Int : NSView] = [:]

    // MARK: - Properties

    /// The map to be displayed.
	///
    /// Must be set after the mapRect.
    private var mapImage: NSImage? {
        didSet {
            guard let mapImage = mapImage else {
                image = nil
                return
            }
            mapImage.size = mapRect.size
            image = mapImage
        }
    }
    private var mapDimensions: (width: CGFloat, height: CGFloat)?


    /// Calculates a CGRect describing the maximum size and its corresponding inset such that the map will be displayed within the bounds of and centred relative to the minimap view.
    private var mapRect: CGRect {
        guard let mapDimensions = mapDimensions else {
            return bounds
        }
        let widthFactor = bounds.width / mapDimensions.width
        let heightFactor = bounds.height / mapDimensions.height
        let factor = widthFactor < heightFactor ? widthFactor : heightFactor

        let width = mapDimensions.width * factor
        let height = mapDimensions.height * factor
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
        if startRects[allyTeam] != nil {
            removeStartRect(for: allyTeam)
        }

        // Cache to avoid re-calculating
        let mapRect = self.mapRect
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
            _self.mapImage = nil
            _self.image = #imageLiteral(resourceName: "Caution")
        }
    }

    func setMapDimensions(_ width: Int, _ height: Int) {
        mapDimensions = (CGFloat(width), CGFloat(height))
    }

    /// Asynchronously converts image data into an image and displays a new map with the given aspect ratio. If image generation fails, the view
    /// assumes a "map unknown" state
    func displayMapImage(for imageData: [RGB565Color], dimension: Int) {
        NSImage.fromRGB565Pixels(imageData, width: dimension, height: dimension) { [weak self] maybeImage in
            executeOnMain { [weak self] in
                if let self = self,
                    let image = maybeImage {
                    self.mapImage = image
                }
            }
        }
    }

    // MARK: - Associated types

    struct Map {
        let image: NSImage
        let width: CGFloat
        let height: CGFloat
    }
}
