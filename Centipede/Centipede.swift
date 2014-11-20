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
	
	class Segment : SKSpriteNode {
		private var direction : Direction
		private let nextSegment : Segment?
		private var directionOnCollide = Direction.Down
		
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
	
		func setDirectionOnCollide(direction:Direction) {
			directionOnCollide = direction
		}
		
		func getDirectionOnCollide() -> Direction {
			return directionOnCollide
		}
		
		func move(directions:[(direction:Direction, dest:CGFloat)]) {
			
		}
		
		func move(directions:[Direction]) {
			//cancel animations
			removeAllActions()
			
			var actions = [SKAction]()
			
			for direction in directions {
        		switch direction {
    			case .Right:
					let x = scene!.size.width
    				let angle = Angle.Degrees(0)
					actions.append(createMoveAction(direction, dest:x, angle:angle))
    				break
    				
    			case .Left:
					let x = CGFloat(0+size.width/2)
    				let angle = Angle.Degrees(180)
					actions.append(createMoveAction(direction, dest:x, angle:angle))
    				break
    				
    			case .Down:
					//TODO clean up
					let gameScene = scene? as GameScene
					let (i, j) = gameScene.pointToPosition(position)
					var pos = gameScene.positionToPoint(i-1, j:j)
					let y = max(0+size.height/2, pos.y)
    				let angle = Angle.Degrees(270)
					actions.append(createMoveAction(direction, dest:y, angle:angle))
    				break
					
    			case .Up:
					//TODO clean up
					let gameScene = scene? as GameScene
					let (i, j) = gameScene.pointToPosition(position)
					var pos = gameScene.positionToPoint(i+1, j: j)
					let y = min(gameScene.size.height-size.height/2, pos.y)
    				let angle = Angle.Degrees(90)
					actions.append(createMoveAction(direction, dest:y, angle:angle))
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
    	
		func createMoveAction(direction:Direction, dest:CGFloat, angle:Angle) -> SKAction {
			let rotate = SKAction.rotateToAngle(CGFloat(angle.radians.value), duration: 0.0625, shortestUnitArc:true)
    		var move : SKAction!
    		
    		if direction == Direction.Down || direction == Direction.Up {
				let dist = fabs(dest - position.y)
    			let time = dist/CentipedeContants.kSpeed
    			move = SKAction.moveToY(dest, duration:NSTimeInterval(time))
    		} else if direction == Direction.Left || direction == Direction.Right {
    			let dist = fabs(dest - position.x)
    			let time = dist/CentipedeContants.kSpeed
    			move = SKAction.moveToX(dest, duration:NSTimeInterval(time))
			} else {
				fatalError("Segment : unhandled direction")
			}
			
			let setDirection = SKAction.runBlock({
				self.direction = direction
			})

			return SKAction.sequence([setDirection, SKAction.group([rotate, move])])
    	}
	}
}