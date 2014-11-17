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
			scene.addChild(segment)
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
	class Segment : SKSpriteNode {
		private var direction : Direction
		private let nextSegment : Segment?
		
		init(imageNamed:String, direction:Direction, nextSegment:Segment?) {
			let texture = SKTexture(imageNamed:imageNamed)
			self.direction = direction
			self.nextSegment = nextSegment
			super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
		}

		required init(coder aDecoder: NSCoder) {
			//TODO decode segment
			direction = Direction.None
			super.init(coder: aDecoder)
		}
		
		override func encodeWithCoder(aCoder: NSCoder) {
			//TODO encode segment
	        super.encodeWithCoder(aCoder)
		}
	
		
		func getNext() -> Segment? {
			return nextSegment
		}
		
		func move(directions:[Direction]) {
			//cancel animations
			removeAllActions()
			
			var actions = [SKAction]()
			
			for direction in directions {
        		switch direction {
    			case .Right:
					let destX = scene!.size.width
    				let angle = Angle.Degrees(0)
					actions.append(createMoveAction(direction, dest: destX, angle:angle, animUpDown: false))
    				break
    				
    			case .Left:
    				let destX = CGFloat(0)
    				let angle = Angle.Degrees(-180)
					actions.append(createMoveAction(direction, dest: destX, angle:angle, animUpDown: false))
    				break
    				
    			case .Down:
					//TODO clean up
					let gameScene = scene? as GameScene
					let (i, j) = gameScene.pointToPosition(position)
					let destPos = gameScene.positionToPoint(i-1, j:j)
    				let angle = Angle.Degrees(-90)
					actions.append(createMoveAction(direction, dest:destPos.y, angle:angle, animUpDown:true))
    				break
					
    			case .Up:
					//TODO clean up
					let gameScene = scene? as GameScene
					let (i, j) = gameScene.pointToPosition(position)
					let destPos = gameScene.positionToPoint(i+1, j: j)
    				let angle = Angle.Degrees(90)
					actions.append(createMoveAction(direction, dest:destPos.y, angle:angle, animUpDown:true))
    				break
					
    			default:
    				break
        		}
			}
			
    		runAction(SKAction.sequence(actions))
		}
		
		func getDirection() -> Direction {
			return direction
		}
    	
		private func createMoveAction(direction:Direction, dest:CGFloat, angle:Angle, animUpDown:Bool) -> SKAction {
    		let rotate = SKAction.rotateToAngle(CGFloat(angle.radians.value), duration: 0.25)
    		var move : SKAction!
    		
    		if animUpDown {
				let dist = fabs(dest - position.y)
    			let time = dist/CentipedeContants.kSpeed
    			move = SKAction.moveToY(dest, duration:NSTimeInterval(time))
    		} else {
    			let dist = fabs(dest - position.x)
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