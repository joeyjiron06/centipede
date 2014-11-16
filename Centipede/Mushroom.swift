//
//  Mushroom.swift
//  Centipede
//
//  Created by Joey Jiron Jr on 11/15/14.
//  Copyright (c) 2014 ccc. All rights reserved.
//

import Foundation
import SpriteKit

struct Mushrooms {
	static let Full = "mushroom"
}

class Mushroom {
	
	private let node : SKSpriteNode
	
	
	init(imageName:String) {
		node = SKSpriteNode(imageNamed:imageName)
	}
	
	func getNode() -> SKSpriteNode {
		return node
	}
}