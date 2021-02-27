//
//  MinimapView.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 14/11/19.
//  Copyright © 2019 MasterBel2. All rights reserved.
//

import Cocoa
import UberserverClientCore

final class MinimapView: NSImageView, ReceivesBattleroomUpdates, ReceivesBattleUpdates {

    // MARK: - View Components

    private var startRects: [Int : StartRectOverlayView] = [:]

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

    private func displayMapUnknown() {
        executeOnMain(target: self) { _self in
            _self.mapImage = nil
            _self.image = #imageLiteral(resourceName: "Caution")
        }
    }

    private func setMapDimensions(_ width: Int, _ height: Int) {
        mapDimensions = (CGFloat(width), CGFloat(height))
        executeOnMain(target: self) { _self in
            _self.startRects.forEach({ $0.value.adjustFrame(for: _self.mapRect) })
        }
    }

    /// Asynchronously converts image data into an image and displays a new map with the given aspect ratio. If image generation fails, the view
    /// assumes a "map unknown" state
    private func displayMapImage(for imageData: [RGB565Color], dimension: Int) {
        NSImage.fromRGB565Pixels(imageData, width: dimension, height: dimension) { [weak self] maybeImage in
            executeOnMain { [weak self] in
                if let self = self,
                    let image = maybeImage {
                    self.mapImage = image
                }
            }
        }
    }
    
    // MARK: - Battle Updates
    
    private let minimapLoadQueue = DispatchQueue(label: "Minimap Load Queue", qos: .userInitiated)
    
    func mapDidUpdate(to map: Battle.MapIdentification) {
        displayMapUnknown()
    }
    
    func loadedMapArchive(_ mapArchive: MapArchive, checksumMatch: Bool, usedPreferredEngineVersion: Bool) {
        setMapDimensions(mapArchive.width, mapArchive.height)
        mapArchive.miniMap.loadMinimaps(mipLevels: Range(0...5), queue: minimapLoadQueue) { [weak self] result in
            guard let self = self,
                  let (data, dimension) = result else { return }
            self.displayMapImage(for: data, dimension: dimension)
        }
    }
    
    // MARK: - Battleroom Updates

    func addStartRect(_ rect: StartRect, for allyTeam: Int) {
        executeOnMain { [weak self] in
            self?._addStartRect(rect, for: allyTeam)
        }
    }

    private func _addStartRect(_ rect: StartRect, for allyTeam: Int) {
        if startRects[allyTeam] != nil {
            removeStartRect(for: allyTeam)
        }

        let view = StartRectOverlayView.loadForAllyTeam(allyTeam, unscaledRect: rect, mapRect: mapRect)
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

    // MARK: - Associated types

    struct Map {
        let image: NSImage
        let width: CGFloat
        let height: CGFloat
    }
}
