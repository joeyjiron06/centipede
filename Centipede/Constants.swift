//
//  Constants.swift
//  Centipede
//
//  Created by Joey Jiron Jr on 11/16/14.
//  Copyright (c) 2014 ccc. All rights reserved.
//

import Foundation
import CoreGraphics

struct Sizes {
	static var Mushroom : CGSize!// = CGSize(width: 20, height: 20)
	static var Segment = Mushroom
	static let SpaceShip = CGSize(width:45, height:45)
	static let Bullet = CGSize(width:5, height:10)
}

struct Categories {
    static let None : UInt32 = 0
    static let All : UInt32 = UInt32.max
    static let Segment : UInt32 = 1
    static let Bounds : UInt32 = (1 << 1)
    static let Mushroom : UInt32 = (1 << 2)
	static let Bullet : UInt32 = (1 << 3)
    		
    static let SegmentAndMushroom =  Segment | Mushroom
    static let BulletAndMushroom =  Bullet | Mushroom
    static let BulletAndSegment =  Bullet | Segment
}

struct Names {
	static let SpaceShip = "spaceship"
	static let Mushroom = "mushroom"
	static let Segment = "segment"
}
