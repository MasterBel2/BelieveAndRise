//
//  UInt16+RGB.swift
//  SpringMapConverter
//
//  Created by Belmakor on 9/1/17.
//  Copyright © 2017 MasterBel2. All rights reserved.
//
import Foundation

typealias RGB565Color = UInt16
typealias RGBAColor = UInt32

extension RGB565Color {
	
	/// convert a single RGB565 (16 bit) pixel to a RGBA (32 bit) pixel
	var rgbaValue: RGBAColor {
		let rgb = UInt32(CFSwapInt16LittleToHost(self))
		
		let r5 = (rgb >> 11) & 0x1F
		let g6 = (rgb >> 5)  & 0x3F
		let b5 = (rgb)       & 0x1F
		
		let r8 = (r5 << 3)
		let g8 = (g6 << 2)
		let b8 = (b5 << 3)
		
		return (b8 << 16) | (g8 << 8) | r8 | 0xFF000000
	}
	
	/// the red component of a RGB565 pixel (5 bits)
	var red:   UInt16 { return (self >> 11) & 0x1F }
	
	/// the green component of a RGB565 pixel (6 bits)
	var green: UInt16 { return (self >> 5)  & 0x3F }
	
	/// the blue component of a RGB565 pixel (5 bits)
	var blue:  UInt16 { return (self)       & 0x1F }
	
	/// pack red, green, blue values into a single RGB565 pixel value
	static func pack(red: UInt16, green: UInt16, blue: UInt16) -> RGB565Color {
		return ((red & 0x1F) << 11) | ((green & 0x3F) << 5) | (blue & 0x1F)
	}
	
}
