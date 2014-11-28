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
	static let kSpeedPerMove = 0.0625
}


class Centipede {

	private let TAG = "Centipede"
	
	private var segments = [Segment]()
	private var isMoving = false
	
	init(numSegments:Int, startPoint:CGPoint) {
		segments = createSegments(numSegments, startPoint:startPoint)
	}
	
	private func createSegments(numSegments:Int, startPoint:CGPoint) -> [Segment] {
		var segments = [Segment]()
		
		var prevSegment : Segment?
		
		for i in 0..<numSegments {
			let x = startPoint.x - (CGFloat(i)*Sizes.Segment.width)
			let y = startPoint.y
			let position = CGPoint(x: x, y: y)
			
			let segment = Segment(imageNamed:"segment", direction:Direction.Right, nextSegment:prevSegment)
			segment.size = Sizes.Segment
			segment.name = Names.Segment
			segment.position = position
			segment.physicsBody = SKPhysicsBody(circleOfRadius: segment.size.width/2)
			segment.physicsBody?.dynamic = true
			segment.physicsBody?.categoryBitMask = Categories.Segment
			segment.physicsBody?.contactTestBitMask = Categories.Bounds
			segment.physicsBody?.collisionBitMask = Categories.None
			segment.physicsBody?.usesPreciseCollisionDetection = true
			
			prevSegment = segment

			segments.append(segment)
		}
		
		return segments
	}
	
	func addToScene(scene:SKScene) {
		for segment in segments {
			scene.addChild(segment)
		}
	}
	
	private func getHead() -> Segment {
		return segments.first!
	}
	
	private func getTail() -> Segment {
		return segments.last!
	}
	
	func startMoving(direction:Direction) {
		if !isMoving {
			isMoving = true
			move()
		}
	}
	
	func stopMoving() {
		if isMoving {
			cancelAnims()
			isMoving = false
		}
	}
	
	private func move() {
		for segment in segments {
			moveSegment(segment)
		}
	}
	
	private func moveSegment(segment:Segment) {
		let move = findNextMove(segment)
		let action = SKAction.sequence([move, SKAction.runBlock( { self.moveSegment(segment) } )])
		segment.runAction(action)
	}
	
	private func cancelAnims() {
		for segment in segments {
			segment.removeAllActions()
		}
	}
	
	private func makeMoveToSegment(fromSegment:Segment, toSegment:Segment) -> SKAction {
		let scene = fromSegment.scene as GameScene
		let (row, col) = scene.pointToPosition(toSegment.position)
		let point = scene.positionToPoint(row, j: col)
		let move = fromSegment.createMoveAction(toSegment.getDirection(), dest: point)
		return move
	}

	private func findNextMove(segment:Segment) -> SKAction {
		var nextMove : SKAction
		
		switch segment.direction {
		case Direction.Down, Direction.Up:
			nextMove = makeMoveInOppsiteIfPossible(segment)
			break
		
		default:
			if isMovePossible(segment, direction:segment.getDirection()) {
				nextMove = makeMoveInDirection(segment, direction: segment.getDirection())
			} else {
				nextMove = makeMoveInBestDirection(segment)
			}
			break
		}
		
		return nextMove
	}
	
	private func makeMoveInOppsiteIfPossible(segment:Segment) -> SKAction {
		var move : SKAction?
		
		if segment.mostRelevantPrevDirection != nil {
			var direction = segment.mostRelevantPrevDirection!.getOpposite()
			
			if isMovePossible(segment, direction:direction) {
				move = makeMoveInDirection(segment, direction:direction)
			} else {
				direction = segment.mostRelevantPrevDirection!
				
				if isMovePossible(segment, direction: direction)  {
					move = makeMoveInDirection(segment, direction: direction)
				}
			}
		}
		
		if move == nil {
			move = makeMoveInBestDirection(segment)
		}
		
		return move!
	}
	
	private func isMovePossible(segment:Segment, direction:Direction) -> Bool {
		return !willCollideIfMovesInDirection(segment, direction: direction)
				&& willStayInBounds(segment, direction: direction)
	}
	
	private func makeMoveInDirection(segment:Segment, direction:Direction) -> SKAction {
		let point = nextPoint(segment, direction: direction)
		return segment.createMoveAction(direction, dest: point)
	}
	
	private func makeMoveInDirection(segment:Segment, direction:Direction, doneBlock:dispatch_block_t?) -> SKAction {
		let point = nextPoint(segment, direction:direction)
		let move = segment.createMoveAction(direction, dest: point)
		if doneBlock != nil {
			return SKAction.sequence([move, SKAction.runBlock(doneBlock!)])
		} else {
			return move
		}
	}
	
	private func willCollideIfMovesInDirection(segment:Segment, direction:Direction) -> Bool {
		let scene = segment.scene!
		let point = nextPoint(segment, direction:direction)
		let node = scene.nodeAtPoint(point)
		return node.name == Names.Mushroom
	}
	
	private func willStayInBounds(segment:Segment, direction:Direction) -> Bool {
		let scene = segment.scene
		let point = nextPoint(segment, direction:direction)
		return point.x >= segment.size.width/2 && point.x < scene?.size.width
			&& point.y >= segment.size.height/2 && point.y < scene?.size.height
	}
	
	private func isPointInBounds(point:CGPoint, scene:SKScene) -> Bool {
		return point.x >= 0 && point.x < scene.size.width
			&& point.y >= 0 && point.y < scene.size.height
	}
	
	private func nextPoint(segment:Segment, direction:Direction) -> CGPoint {
		let scene = segment.scene as GameScene
		let (row, col) = scene.pointToPosition(segment.position)

		switch direction {
		case .Left:
			return scene.positionToPoint(row, j: col-1)
		case .Right:
			return scene.positionToPoint(row, j: col+1)
		case .Up:
			return scene.positionToPoint(row+1, j: col)
		case .Down:
			return scene.positionToPoint(row-1, j: col)
		default:
			fatalError("unhandeled direction")
		}
	}
	
	private func makeMoveInBestDirection(segment:Segment) -> SKAction {
		let direction = segment.getDirectionOnCollide()
		
		switch direction {
		case Direction.Left, Direction.Right:
			let point = nextPoint(segment, direction:direction)
			let move = segment.createMoveAction(direction, dest: point)
			return move
			
		case Direction.Down, Direction.Up:
			
			if isMovePossible(segment, direction: direction) {
				return makeMoveInDirection(segment, direction: direction)
			}
			
			if isMovePossible(segment, direction: direction.getOpposite()) {
				let setDirOnCollide = { segment.setDirectionOnCollide(direction.getOpposite()) }
				return makeMoveInDirection(segment, direction: direction.getOpposite(), doneBlock:setDirOnCollide)
			}
			
			if isMovePossible(segment, direction: Direction.Right) {
				let setDirOnCollide = { segment.setDirectionOnCollide(direction.getOpposite()) }
				return makeMoveInDirection(segment, direction: Direction.Right, doneBlock:nil)
			}
			
			if isMovePossible(segment, direction: Direction.Left) {
				let setDirOnCollide = { segment.setDirectionOnCollide(direction.getOpposite()) }
				return makeMoveInDirection(segment, direction: Direction.Left, doneBlock:nil)
			}
			
			
		default:
			break
		}
		fatalError("could not find best move!")
	}
}

class Segment : SKSpriteNode {
	private var direction : Direction
	private var mostRelevantPrevDirection : Direction?
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
	
	func getDirection() -> Direction {
		return direction
	}
	
	func wasHitByBullet() {
		self.texture = SKTexture(imageNamed: "segment_hit")
	}
	
	private func getNext() -> Segment? {
		return nextSegment
	}
	
	private func setDirectionOnCollide(direction:Direction) {
		directionOnCollide = direction
	}
	
	private func getDirectionOnCollide() -> Direction {
		return directionOnCollide
	}
	
	private func directionToAngle(direction:Direction) -> Angle {
		switch direction {
		case .Left:
			return Angle.Degrees(-180)
		case .Right:
			return Angle.Degrees(0)
		case .Up:
			return Angle.Degrees(90)
		case .Down:
			return Angle.Degrees(-90)
		default:
			return Angle.Degrees(0)
		}
	}
	
	private func isRevelevatPrevDirection(direction:Direction) -> Bool {
		return direction == Direction.Left || direction == Direction.Right
	}
	
	private func createMoveAction(direction:Direction, dest:CGPoint) -> SKAction {
		var move : SKAction!
		
		if direction == Direction.Down || direction == Direction.Up {
			let time = CentipedeContants.kSpeedPerMove
			move = SKAction.moveToY(dest.y, duration:NSTimeInterval(time))
		} else if direction == Direction.Left || direction == Direction.Right {
			let time = CentipedeContants.kSpeedPerMove
			move = SKAction.moveToX(dest.x, duration:NSTimeInterval(time))
		} else {
			fatalError("Segment : unhandled direction")
		}
		
		let setDirection = SKAction.runBlock({
			if self.isRevelevatPrevDirection(self.direction) {
				self.mostRelevantPrevDirection = self.direction
			}
			self.direction = direction
		})
		
		let angle = CGFloat(directionToAngle(direction).radians.value)
		let rotate = SKAction.rotateToAngle(angle, duration: 0.0625, shortestUnitArc:true)
		return SKAction.sequence([setDirection, SKAction.group([rotate, move])])
	}
}