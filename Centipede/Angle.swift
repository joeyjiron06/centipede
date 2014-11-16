//
//  Angle.swift
//  Centipede
//
//  Created by Joey Jiron Jr on 11/13/14.
//  Copyright (c) 2014 ccc. All rights reserved.
//

import Foundation

func DegreesToRadians (value:Double) -> Double {
	return value * M_PI / 180.0
}

func RadiansToDegrees (value:Double) -> Double {
	return value * 180.0 / M_PI
}

enum Angle {
	case Radians(Double)
	case Degrees(Double)
 
	var value: Double {
		switch(self) {
		case .Radians(let v):
			return v
		case .Degrees(let v):
			return v
			}
	}
 
	var radians: Angle {
		switch(self) {
		case .Radians(_):
			return self
		case .Degrees(let value):
			return .Radians(DegreesToRadians(value))
			}
	}
 
	var degrees: Angle {
		switch(self) {
		case .Degrees(let value):
			return .Degrees(RadiansToDegrees(value))
		case .Radians(_):
			return self
			}
	}
}

extension Double {
 
	init(_ angle:Angle) {
		self.init(angle.value)
	}
 
}