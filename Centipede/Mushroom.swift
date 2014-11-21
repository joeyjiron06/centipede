//
//  Mushroom.swift
//  Centipede
//
//  Created by Joey Jiron Jr on 11/15/14.
//  Copyright (c) 2014 ccc. All rights reserved.
//

import Foundation
import SpriteKit


class Mushroom : SKSpriteNode {
	
	
	
	private var health = 100
	
	func wasHitByBulltet() {
		health -= 33
		
		if health <= 0 {
			removeFromParent()
		} else if health <= 33 {
			self.texture = SKTexture(imageNamed: "mushroom_hit_3")
		} else if health <= 66 {
			self.texture = SKTexture(imageNamed: "mushroom_hit_2")
		} else if health <= 100 {
			self.texture = SKTexture(imageNamed: "mushroom_hit_1")
		}
	}
		
}