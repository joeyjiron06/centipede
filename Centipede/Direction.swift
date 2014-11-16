//
//  Direction.swift
//  Centipede
//
//  Created by Joey Jiron Jr on 11/13/14.
//  Copyright (c) 2014 ccc. All rights reserved.
//

enum Direction {
	case None
	case Up
	case Down
	case Left
	case Right;
	
	func getOpposite() -> Direction {
		switch self {
			case .None:
				return .None
			case .Up:
				return .Down
			case .Down:
				return .Up
			case .Left:
				return .Right
			case .Right:
				return .Left
			default:
				return .None
		}
	}
	
	func isOpposite(otherDirection:Direction) -> Bool {
		return getOpposite() == otherDirection
	}
}
	