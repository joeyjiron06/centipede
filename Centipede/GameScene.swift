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

	let kShipSize = CGSize(width:45, height:45)
	let kBulletSize = CGSize(width:5, height:10)
	let kNumberOfMushroomsInWidth = 20
	var kMushroomSize : CGSize!
	let kCentipedeNumNodes = 1
	
	struct PhysicsCategory {
		static let None : UInt32 = 0
		static let All : UInt32 = UInt32.max
		static let Segment : UInt32 = 1
		static let Bounds : UInt32 = (1 << 1)
		static let Mushroom : UInt32 = (1 << 2)
		
		static let SegmentAndMushroom =  Segment | Mushroom
	}
	
	private enum Bound : UInt8 {
		case Left = 0b1
		case Right = 0b10
		case Top = 0b100
		case Bottom = 0b1000
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
		self.physicsBody?.categoryBitMask = PhysicsCategory.Bounds
		self.physicsBody?.contactTestBitMask = PhysicsCategory.Segment
		self.physicsBody?.collisionBitMask = PhysicsCategory.None
	
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
				let shouldAdd : Bool = (topLeftNeighbor.physicsBody?.categoryBitMask != PhysicsCategory.Mushroom)//TODO: use better id
										&& (topRightNeightbor.physicsBody?.categoryBitMask != PhysicsCategory.Mushroom)
										&& randBool(20)
				
				if shouldAdd {
            		let mushroom = Mushroom(imageName:Mushrooms.Full)
            		let node = mushroom.getNode()
            		node.size = kMushroomSize
					node.setScale(0.75)
					node.name = Mushrooms.Full
					node.physicsBody = SKPhysicsBody(texture:SKTexture(imageNamed:"mushroom-physicsbody"), size: node.size)
					node.physicsBody?.dynamic = false
					node.physicsBody?.categoryBitMask = PhysicsCategory.Mushroom
					node.physicsBody?.contactTestBitMask = PhysicsCategory.Segment
					node.physicsBody?.collisionBitMask = PhysicsCategory.None
            		node.position = positionToPoint(i, j:j)
            		addChild(node)
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
			
			let segment = Centipede.Segment(size:kMushroomSize, imageName: CentipedeContants.kSegmentImageName, direction:Direction.None, position:position, nextSegment:prevSegment)
			segment.getNode().name = SceneObjNames.kSegment
			segment.getNode().physicsBody?.dynamic = true
			segment.getNode().physicsBody?.categoryBitMask = PhysicsCategory.Segment
			segment.getNode().physicsBody?.contactTestBitMask = PhysicsCategory.Bounds
			segment.getNode().physicsBody?.collisionBitMask = PhysicsCategory.None
			segment.getNode().physicsBody?.usesPreciseCollisionDetection = true
			
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
	
	//TODO remove
	private func findSegment(contact:SKPhysicsContact) -> Centipede.Segment? {
		var segmentNode : SKNode? = findNode(PhysicsCategory.Segment, contact:contact)
		var segment : Centipede.Segment?
		
		if segmentNode != nil {
			segment = segmentNode!.userData!.objectForKey("segment") as? Centipede.Segment
		}
		
		return segment
	}
	
	//TODO remove
	private func findSegmentBound(contact:SKPhysicsContact) -> (segment:Centipede.Segment?, bound:SKNode?) {
		var segmentNode : SKNode? = findNode(PhysicsCategory.Segment, contact:contact)
		var bound : SKNode? = findNode(PhysicsCategory.Bounds, contact: contact)
		
		var segment : Centipede.Segment?
		
		if segmentNode != nil {
			segment = segmentNode!.userData!.objectForKey("segment") as? Centipede.Segment
		}
		
		return (segment, bound)
	}

/* - SKPhysicsContactDelegate */
	
	func didBeginContact(contact: SKPhysicsContact) {
		
		let (segment, bound) = findSegmentBound(contact)

	
		if segment != nil && bound != nil {
			segmentDidCollideWithBound(segment!, bound:bound!, point:contact.contactPoint)
		}
		
		
		let contactBitMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
		
		
		if contactBitMask == PhysicsCategory.SegmentAndMushroom {
			let segment = findSegment(contact)
			let mushroom = findNode(PhysicsCategory.Mushroom, contact: contact)
			segmentDidCollideWithMushroom(segment!, mushroom: mushroom!, point:contact.contactPoint)
		}
		
		
	}
	
/* - Collided Functions */
	
	
	private func segmentDidCollideWithBound(segment:Centipede.Segment, bound:SKNode, point:CGPoint) {
		let threshold = CGFloat(3)//TODO change threshold to use segment size
		var bound : UInt8?
		
		if point.x == 0 || point.x < threshold {
			bound = Bound.Left.toRaw()
		}
		
		if point.x == size.width || point.x > size.width-threshold {
			bound = (bound == nil) ? Bound.Right.toRaw() : (bound! | Bound.Right.toRaw())
		}
		
		if point.y == 0 || point.y < threshold {
			bound = (bound == nil) ? Bound.Bottom.toRaw() : (bound! | Bound.Bottom.toRaw())
		}
		
		if point.y == size.height || point.y > size.height - threshold {
			bound = (bound == nil) ? Bound.Top.toRaw() : (bound! | Bound.Top.toRaw())
		}
		
		if bound != nil {
			let node = segment.getNode()
			
			switch bound! {
			case Bound.Right.toRaw(), Bound.Left.toRaw():
				let canMoveDown = node.position.y-node.size.height >= 0
				if canMoveDown {
    				segment.move([Direction.Down, segment.getDirection().getOpposite()])
				} else {
					segment.move([Direction.Up])
				}
				break
				
			case Bound.Top.toRaw(), Bound.Bottom.toRaw():
				let canMoveLeft = node.position.x-node.size.width >= 0
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
			Logger.log(TAG, message: "segmentDidCollideWithBound:" + "bound is nil")
		}
	}
	
	private func segmentDidCollideWithMushroom(segment:Centipede.Segment, mushroom:SKNode, point:CGPoint) {
		let mushroomPoint = mushroom.position
		let direction = segment.getDirection()
		
		switch (direction) {
		case Direction.Left:
			segment.move([Direction.Down, direction.getOpposite()])
			break
		case Direction.Right:
			segment.move([Direction.Down, direction.getOpposite()])
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
