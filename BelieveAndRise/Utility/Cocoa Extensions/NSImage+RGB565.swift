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

        let pixels = rgb565Pixels.map { $0.rgbaValue }
        let destinationCount = pixels.count * 4

        pixels.withUnsafeBufferPointer { pixelBuffer in
            let data = Data(buffer: pixelBuffer)
            data.copyBytes(to: destination, count: destinationCount)
        }

        // An alternate solution with 7x the run time:

//        pixels.withUnsafeBytes { pixelBytes in
//            let pointer = UnsafeMutableRawBufferPointer(start: destination, count: destinationCount)
//            pointer.copyBytes(from: pixelBytes)
//        }
        
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
