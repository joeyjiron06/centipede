//
//  Centipede.swift
//  Centipede
//
//  Created by Joey Jiron Jr on 11/10/14.
//  Copyright (c) 2014 ccc. All rights reserved.
//

import Foundation
import SpriteKit

struct CentipedeContants {
	static let NAME = "Centipede"
	static let kSegmentImageName = "segment"
	static let kSpeed = CGFloat(150)
}


class Centipede {

	
	private let model : Model
	
	init(segments:Array<Segment>) {
		model = Model(segments:segments)
	}
	
	func addToScene(scene:SKScene) {
		for (i, segment) in enumerate(model.segments) {
			let node = segment.getNode()
			scene.addChild(node)
		}
	}
	
	private func getHead() -> Segment {
		return model.segments.first!
	}
	
	private func getTail() -> Segment {
		return model.segments.last!
	}

	func move(direction:Direction) {
		let head = getHead()
		let node = head.getNode()
		
		for segment in model.segments {
			if segment === head {
				segment.move([direction])
			} else {
				switch segment.direction {
					case .None:
						segment.move([direction])
						break
					
					default:
						println("not moving segment")
						break
				}
			}
		}
	}
	
	
/* - Model */
	
	private class Model {
		let segments = [Segment]()
		
		init(segments:Array<Segment>) {
			for segment in segments {
				self.segments.append(segment)
			}
		}
	}
	
	//TODO make it extend node
	class Segment {
		private let imageName : String
		private var direction : Direction
		private let skNode : SKSpriteNode
		private let nextSegment : Segment?
		
		init(size:CGSize, imageName:String, direction:Direction, position:CGPoint, nextSegment:Segment?) {
			self.imageName = imageName
			self.direction = direction
			self.nextSegment = nextSegment
			skNode = SKSpriteNode(imageNamed: imageName)
			skNode.size = size
			skNode.position = position
			skNode.physicsBody = SKPhysicsBody(circleOfRadius:skNode.size.width/2)
			skNode.userData = NSMutableDictionary()
			skNode.userData?.setValue(self, forKey: "segment")
		}
		
		func setPosition(position:CGPoint) {
			self.skNode.position = position
		}
		
		func getNode() -> SKSpriteNode {
			return skNode
		}
		
		func getNext() -> Segment? {
			return nextSegment
		}
		
		func move(directions:[Direction]) {
    		let node = getNode()
			//cancel animations
			node.removeAllActions()
			
			var actions = [SKAction]()
			
			for direction in directions {
        		switch direction {
    			case .Right:
					let destX = node.scene!.size.width
    				let angle = Angle.Degrees(0)
					actions.append(createMoveAction(direction, node:node, dest: destX, angle:angle, animUpDown: false))
    				break
    				
    			case .Left:
    				let destX = CGFloat(0)
    				let angle = Angle.Degrees(-180)
					actions.append(createMoveAction(direction, node:node, dest: destX, angle:angle, animUpDown: false))
    				break
    				
    			case .Down:
					//TODO clean up
					let gameScene = node.scene? as GameScene
					let (i, j) = gameScene.pointToPosition(node.position)
					let destPos = gameScene.positionToPoint(i-1, j:j)
    				let angle = Angle.Degrees(-90)
					actions.append(createMoveAction(direction, node:node, dest:destPos.y, angle:angle, animUpDown:true))
    				break
					
    			case .Up:
					//TODO clean up
					let gameScene = node.scene? as GameScene
					let (i, j) = gameScene.pointToPosition(node.position)
					let destPos = gameScene.positionToPoint(i+1, j: j)
    				let angle = Angle.Degrees(90)
					actions.append(createMoveAction(direction, node:node, dest:destPos.y, angle:angle, animUpDown:true))
    				break
					
    			default:
    				break
        		}
			}
			
    		node.runAction(SKAction.sequence(actions))
		}
		
		func getDirection() -> Direction {
			return direction
		}
    	
		private func createMoveAction(direction:Direction, node:SKSpriteNode, dest:CGFloat, angle:Angle, animUpDown:Bool) -> SKAction {
    		let rotate = SKAction.rotateToAngle(CGFloat(angle.radians.value), duration: 0.25)
    		var move : SKAction!
    		
    		if animUpDown {
				let dist = fabs(dest - node.position.y)
    			let time = dist/CentipedeContants.kSpeed
    			move = SKAction.moveToY(dest, duration:NSTimeInterval(time))
    		} else {
    			let dist = fabs(dest - node.position.x)
    			let time = dist/CentipedeContants.kSpeed
    			move = SKAction.moveToX(dest, duration:NSTimeInterval(time))
    		}
			
			let setDirection = SKAction.runBlock({
				self.direction = direction
			})

			return SKAction.sequence([setDirection, SKAction.group([rotate, move])])
    	}
	}
}