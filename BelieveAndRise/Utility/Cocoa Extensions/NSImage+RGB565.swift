//
//  NSImage+RGB565.swift
//  SpringMapConverter
//
//  Created by Belmakor on 9/1/17.
//  Copyright © 2017 MasterBel2. All rights reserved.
//
import Cocoa

extension NSImage {

    /**
     Creates an image from an array of pixel data, if that the pixel count is exactly equal to the width * height.
     */
	convenience init?(rgb565Pixels: [RGB565Color], width: Int, height: Int) {
		guard rgb565Pixels.count == width * height else {
			print("Invalid arguments to create image from rgb565 data; contained \(rgb565Pixels.count) pixels, but width of \(width) and height of \(height)")
			return nil
		}
		guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSColorSpaceName.deviceRGB, bytesPerRow: width * 4, bitsPerPixel: 32) else {
			print("Couldn't create NSBitmapImageRep object for RGB data")
			return nil
		}
		
		guard let destination = bitmap.bitmapData else {
			print("Couldn't get reference to destination pixel buffer")
			return nil
		}
		
		var pixels = rgb565Pixels.map { $0.rgbaValue }
		let pixelBuffer = UnsafeMutablePointer<UInt32>(&pixels)
		let bytes = UnsafeRawPointer(pixelBuffer).assumingMemoryBound(to: UInt8.self)

		destination.assign(from: bytes, count: pixels.count * 4)
		
		self.init(size: NSSize(width: width, height: height))
		addRepresentation(bitmap)
	}

    /// Asynchronously creates an image from an array of pixel data, and hands it to a completion block.
    static func fromRGB565Pixels(_ pixels: [RGB565Color], width: Int, height: Int, block: @escaping (NSImage?) -> Void) {
        DispatchQueue(label: "ImageFromRGBPixels", qos: .userInteractive).async {
            block(NSImage(rgb565Pixels: pixels, width: width, height: height))
        }
    }
}
