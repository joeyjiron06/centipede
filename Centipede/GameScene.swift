//
//  GameScene.swift
//  Centipede
//
//  Created by Joey Jiron Jr on 11/10/14.
//  Copyright (c) 2014 ccc. All rights reserved.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
	
	let TAG = "GameScene"

	//TODO move to constants
	let kShipSize = CGSize(width:45, height:45)
	let kBulletSize = CGSize(width:5, height:10)
	let kNumberOfMushroomsInWidth = 20
	var kMushroomSize : CGSize!
	let kCentipedeNumNodes = 1
	
	private struct Bound {
		static let Left = UInt8(0x1)
		static let Right = UInt8(0x1 << 1)
		static let Top = UInt8(0x1 << 2)
		static let Bottom = UInt8(0x1 << 3)
	}
	
	struct SceneObjNames {
		static let kSpaceShip = "spaceship"
		static let kSegment = "segment"
	}
	
	private var mCentipedes : Array<Centipede> = []
	private var mCentipede : Centipede!
	private var up : SKSpriteNode!
	private var down : SKSpriteNode!
	private var left : SKSpriteNode!
	private var right : SKSpriteNode!
	
	override func didMoveToView(view: SKView) {
		setupPhysics()

		createMushrooms()
		createArrows()
		
//		let spaceShip = createNewSpaceShip()
//		addChild(spaceShip)

		
		mCentipede = createNewCentipede()
		mCentipede.addToScene(self)
//		mCentipedes.append(centipede)
    }
	
	private func setupPhysics() {
		let size = self.size.width / CGFloat(kNumberOfMushroomsInWidth)
		kMushroomSize = CGSize(width:size , height:size)
		
		self.physicsWorld.gravity = CGVector.zeroVector
		self.physicsWorld.contactDelegate = self
		
		// Now make the edges of the screen a physics object as well
		self.physicsBody = SKPhysicsBody(edgeLoopFromRect:self.view!.frame)
		self.physicsBody?.categoryBitMask = Categories.Bounds
		self.physicsBody?.contactTestBitMask = Categories.Segment
		self.physicsBody?.collisionBitMask = Categories.None
	}
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//		let spaceShip = getSpaceShip()
//		fire(spaceShip.position)
		
		let point = touches.anyObject()?.locationInNode(self)
		
		if point != nil {
			let node = nodeAtPoint(point!)
			if node == up {
				onDirection(Direction.Up)
			} else if node == down {
				onDirection(Direction.Down)
			} else if node == left {
				onDirection(Direction.Left)
			} else if node == right {
				onDirection(Direction.Right)
			}
			
		}
	}
	
	private func onDirection(direction:Direction) {
		mCentipede.move(direction)
	}

	func positionToPoint(i:Int, j:Int) -> CGPoint {
		let x = (CGFloat(j)*kMushroomSize.width) + (kMushroomSize.width/2)
		let y = (CGFloat(i)*kMushroomSize.height) + (kMushroomSize.height)
		return CGPoint(x:x, y:y)
	}
	
	func pointToPosition(point:CGPoint) -> (i:Int, j:Int) {
		let i = Int((point.y - kMushroomSize.height) / (kMushroomSize.height))
		let j = Int((point.x - kMushroomSize.width/2) / kMushroomSize.width)
		return (i:i, j:j)
	}
	
	
/* - Create Methods */
	
	private func createMushrooms() {
		let maxRows = Int(size.height / kMushroomSize.height)
		let maxCols = Int(size.width / kMushroomSize.width)
		let buffer = 3

		for i in buffer..<maxRows-buffer {
			for j in 1..<maxCols-1 {
				let topLeftNeighbor = nodeAtPoint(positionToPoint(i-1, j: j-1))
				let topRightNeightbor =  nodeAtPoint(positionToPoint(i-1, j: j+1))
				let shouldAdd : Bool = (topLeftNeighbor.physicsBody?.categoryBitMask != Categories.Mushroom)//TODO: use better id
										&& (topRightNeightbor.physicsBody?.categoryBitMask != Categories.Mushroom)
										&& randBool(20)
				
				if shouldAdd {
            		let mushroom = Mushroom(imageNamed:Mushrooms.Full)
            		mushroom.size = kMushroomSize
					mushroom.setScale(0.75)
					mushroom.name = Mushrooms.Full
					mushroom.physicsBody = SKPhysicsBody(texture:SKTexture(imageNamed:"mushroom-physicsbody"), size: mushroom.size)
					mushroom.physicsBody?.dynamic = false
					mushroom.physicsBody?.categoryBitMask = Categories.Mushroom
					mushroom.physicsBody?.contactTestBitMask = Categories.Segment
					mushroom.physicsBody?.collisionBitMask = Categories.None
            		mushroom.position = positionToPoint(i, j:j)
            		addChild(mushroom)
				}
			}
		}
	}
	
	private func randBool(percentChance:UInt32) -> Bool {
		let rand = arc4random() % 100
		return rand < percentChance
	}
	
	//TODO: remove arrows and function
	private func createArrows() {
		up = newSpaceShip(CGPoint(x:80, y:kShipSize.height/2 + 70))
		addChild(up)
		
		down = newSpaceShip(CGPoint(x:80, y:kShipSize.height/2 + 10))
		down.zRotation = CGFloat(Angle.Degrees(-180).radians.value)
		addChild(down)
		
		left = newSpaceShip(CGPoint(x:40, y:kShipSize.height/2 + 40))
		left.zRotation = CGFloat(Angle.Degrees(90).radians.value)
		addChild(left)

		right = newSpaceShip(CGPoint(x:120, y:kShipSize.height/2 + 40))
		right.zRotation = CGFloat(Angle.Degrees(-90).radians.value)
		addChild(right)
	}
	
	private func newSpaceShip(position:CGPoint) -> SKSpriteNode {
		let spaceShip = SKSpriteNode(imageNamed:"Spaceship")
		spaceShip.size = kShipSize
		spaceShip.position = position
		return spaceShip
	}
	
	private func createNewSpaceShip() -> SKSpriteNode {
		let scale : CGFloat = 0.25
		let x : CGFloat = size.width/2.0
		let y : CGFloat = kShipSize.height/2 + 20
		
		let spaceShip = SKSpriteNode(imageNamed:"Spaceship")
		spaceShip.name = SceneObjNames.kSpaceShip
		spaceShip.size = kShipSize
		spaceShip.position = CGPoint(x:x, y:y)

		return spaceShip
	}
	
	private func createNewCentipede() -> Centipede {
		let segmentWidth = kMushroomSize.width
		
		let maxRows = Int(size.height / kMushroomSize.height)
		let maxCols = Int(size.width / kMushroomSize.width)
	
		let startPoint = positionToPoint(maxRows-2, j:maxCols/2)

		var segments : Array<Centipede.Segment> = []
		var prevSegment : Centipede.Segment?
		
		for i in 0..<kCentipedeNumNodes {
			let x = startPoint.x - (CGFloat(i)*segmentWidth)
			let y = startPoint.y
			let position = CGPoint(x: x, y: y)
			
			let segment = Centipede.Segment(imageNamed:CentipedeContants.kSegmentImageName, direction:Direction.None, nextSegment:prevSegment)
			segment.size = kMushroomSize
			segment.position = position
			segment.name = SceneObjNames.kSegment
			segment.physicsBody = SKPhysicsBody(circleOfRadius: segment.size.width/2)
			segment.physicsBody?.dynamic = true
			segment.physicsBody?.categoryBitMask = Categories.Segment
			segment.physicsBody?.contactTestBitMask = Categories.Bounds
			segment.physicsBody?.collisionBitMask = Categories.None
			segment.physicsBody?.usesPreciseCollisionDetection = true
			
			prevSegment = segment

			segments.append(segment)
		}
		
		let centipede = Centipede(segments: segments)
		
		return centipede
	}
	
	private func getSpaceShip() -> SKSpriteNode! {
		let spaceShipSKNode = childNodeWithName(SceneObjNames.kSpaceShip)
		return (spaceShipSKNode as? SKSpriteNode)
	}
	
	private func fire(startPosition:CGPoint) {
		let bullet = SKShapeNode(rectOfSize: kBulletSize)
		bullet.fillColor = UIColor.purpleColor()
		bullet.position = startPosition
		
		let moveAction = SKAction.moveToY(size.height+kBulletSize.height, duration: 2.0)
		let removeAction = SKAction.removeFromParent()
		let sequence = SKAction.sequence([moveAction])
		bullet.runAction(sequence)
		
		addChild(bullet)
	}
	
	private func findNode(category:UInt32, contact:SKPhysicsContact) -> SKNode? {
		var node : SKNode?
		
		if category == contact.bodyA.categoryBitMask {
			node = contact.bodyA.node
		} else if category == contact.bodyB.categoryBitMask {
			node = contact.bodyB.node
		}
		
		return node
	}
	
/* - SKPhysicsContactDelegate */
	
	func didBeginContact(contact: SKPhysicsContact) {
		
		let contactBitMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
		
		if contactBitMask == Categories.Segment | Categories.Mushroom {
			let segment = findNode(Categories.Segment, contact: contact) as Centipede.Segment
			let mushroom = findNode(Categories.Mushroom, contact: contact)
			segmentDidCollideWithMushroom(segment, mushroom: mushroom!, point:contact.contactPoint)

		} else if contactBitMask == Categories.Segment | Categories.Bounds {
			
			let segment = findNode(Categories.Segment, contact: contact) as Centipede.Segment
			let bound = findNode(Categories.Bounds, contact: contact)!
			segmentDidCollideWithBound(segment, bound:bound, point: contact.contactPoint)
		}
	}
	
/* - Collided Functions */
	
	
	private func segmentDidCollideWithBound(segment:Centipede.Segment, bound:SKNode, point:CGPoint) {
		var bound : UInt8 = 0
		
		if point.x == 0 || point.x < segment.size.width {
			bound = Bound.Left
		}
		
		if point.x == size.width || point.x > size.width-segment.size.width {
			bound |= Bound.Right
		}
		
		if point.y == 0 || point.y < segment.size.height/2 {
			bound |= Bound.Bottom
		}
		
		if point.y == size.height || point.y > size.height - segment.size.height/2 {
			bound |= Bound.Top
		}
		
		if bound != 0 {
			switch bound {
			case Bound.Right, Bound.Left:
				let canMoveDown = segment.canMoveDownOnCollide() && segment.position.y-segment.size.height >= 0
				if canMoveDown {
    				segment.move([Direction.Down, segment.getDirection().getOpposite()])
				} else {
					segment.move([Direction.Up, segment.getDirection().getOpposite()])
				}
				break
				
			case (Bound.Top|Bound.Right), (Bound.Bottom|Bound.Right), (Bound.Top|Bound.Left), (Bound.Bottom|Bound.Left):
				let canMoveLeft = segment.position.x-segment.size.width >= 0
				let isBottomTouched = (bound & Bound.Bottom) == Bound.Bottom
				segment.setMoveDownOnCollide(!isBottomTouched)
				if canMoveLeft {
    				segment.move([Direction.Left])
				} else {
					segment.move([Direction.Right])
				}
				break
			default:
				break
			}
		} else {
			Logger.log(TAG, message: "segmentDidCollideWithBound:" + "bound is 0")
		}
	}
	
	private func segmentDidCollideWithMushroom(segment:Centipede.Segment, mushroom:SKNode, point:CGPoint) {
		let mushroomPoint = mushroom.position
		let direction = segment.getDirection()
		let firstMove = segment.canMoveDownOnCollide() ? Direction.Down : Direction.Up
		
		switch (direction) {
		case Direction.Left:
			segment.move([firstMove, direction.getOpposite()])
			break
		case Direction.Right:
			segment.move([firstMove, direction.getOpposite()])
			break
			
		case Direction.Up:
			segment.move([Direction.Left])
			break
			
		case Direction.Down:
			segment.move([Direction.Left])
			break
			
		default:
			break
		}

	}
	
}
