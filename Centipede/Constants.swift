//
//  Constants.swift
//  Centipede
//
//  Created by Joey Jiron Jr on 11/16/14.
//  Copyright (c) 2014 ccc. All rights reserved.
//

import Foundation


struct Categories {
    static let None : UInt32 = 0
    static let All : UInt32 = UInt32.max
    static let Segment : UInt32 = 1
    static let Bounds : UInt32 = (1 << 1)
    static let Mushroom : UInt32 = (1 << 2)
    		
    static let SegmentAndMushroom =  Segment | Mushroom
}

struct Names {
	static let Mushroom = "mushroom"
	static let Segment = "segment"
}
