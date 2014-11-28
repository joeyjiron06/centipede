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

	let kNumberOfMushroomsInWidth = 20
	let kCentipedeNumNodes = 7
	
	private var mCentipedes = [Centipede]()
	private var touchDidMove = false
	
	override func didMoveToView(view: SKView) {
		setupPhysics()

		createMushrooms()
		
		let spaceShip = createNewSpaceShip()
		addChild(spaceShip)

		
		let centipede = createNewCentipede()
		centipede.addToScene(self)
		centipede.startMoving(Direction.Right)
		mCentipedes.append(centipede)
    }

	func didBeginContact(contact: SKPhysicsContact) {
		let bitmask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

		if bitmask == Categories.BulletAndMushroom {
			let bullet = getNode(contact, category:Categories.Bullet)
			let mushroom = getNode(contact, category:Categories.Mushroom)
			if bullet != nil && mushroom != nil {
				bulletAndMushroomCollided(bullet!, mushroom:mushroom!)
			}
		} else if bitmask == Categories.BulletAndSegment {
			let bullet = getNode(contact, category:Categories.Bullet)
			let segment = getNode(contact, category: Categories.Segment)
			if bullet != nil && segment != nil {
				bulletAndSementCollided(bullet!, segment: (segment as Segment))
			}
		}
	}
	
	private func bulletAndMushroomCollided(bullet:SKNode, mushroom:SKNode) {
		bullet.removeFromParent()
		
		let mushroomSprite = mushroom as Mushroom
		mushroomSprite.wasHitByBulltet()
	}
	
	private func bulletAndSementCollided(bullet:SKNode, segment:Segment) {
		bullet.removeFromParent()
		segment.wasHitByBullet()
		//TODO split centipedes then continue moving...
	}

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
		touchDidMove = false
	}
	
	override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
		touchDidMove = true
		let newPoint = touches.anyObject()?.locationInNode(self)
		
		if newPoint != nil {
			let spaceShip = getSpaceShip()
			 spaceShip.position.x = newPoint!.x
		}
	}
	
	override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
		if !touchDidMove {
			let spaceShip = getSpaceShip()
			fire(spaceShip.position)
		}
	}
	
	func positionToPoint(i:Int, j:Int) -> CGPoint {
		let x = (CGFloat(j)*Sizes.Mushroom.width) + (Sizes.Mushroom.width/2)
		let y = (CGFloat(i)*Sizes.Mushroom.height) + (Sizes.Mushroom.height)
		return CGPoint(x:x, y:y)
	}
	
	func pointToPosition(point:CGPoint) -> (i:Int, j:Int) {
		let i = Int((point.y - Sizes.Mushroom.height) / (Sizes.Mushroom.height))
		let j = Int((point.x - Sizes.Mushroom.width/2) / Sizes.Mushroom.width)
		return (i:i, j:j)
	}

/* - Get Methods */
	
	private func getNode(contact:SKPhysicsContact, category:UInt32) -> SKNode? {
		if contact.bodyA.categoryBitMask == category {
			return contact.bodyA.node
		} else if contact.bodyB.categoryBitMask == category {
			return contact.bodyB.node
		}
		return nil
	}
	
	private func getMaxRows() -> Int {
		return Int(size.height / Sizes.Mushroom.height)
	}
	
	private func getMaxCols() -> Int {
		return Int(size.width / Sizes.Mushroom.width)
	}
	
	private func getSpaceShip() -> SKSpriteNode! {
		let spaceShipSKNode = childNodeWithName(Names.SpaceShip)
		return (spaceShipSKNode as? SKSpriteNode)
	}
	
	private func setupPhysics() {
		let size = self.size.width / CGFloat(kNumberOfMushroomsInWidth)
		Sizes.Mushroom = CGSize(width:size , height:size)
		
		self.physicsWorld.gravity = CGVector.zeroVector
		self.physicsWorld.contactDelegate = self
		
		// Now make the edges of the screen a physics object as well
		self.physicsBody = SKPhysicsBody(edgeLoopFromRect:self.view!.frame)
		self.physicsBody?.categoryBitMask = Categories.Bounds
		self.physicsBody?.contactTestBitMask = Categories.Segment
		self.physicsBody?.collisionBitMask = Categories.None
	}
	
/* - Create Methods */
	
	private func createMushrooms() {
		let maxRows = getMaxRows()
		let maxCols = getMaxCols()
		
		let buffer = 3

		for i in buffer..<maxRows-buffer {
			for j in 1..<maxCols-1 {
				let topLeftNeighbor = nodeAtPoint(positionToPoint(i-1, j: j-1))
				let topRightNeightbor =  nodeAtPoint(positionToPoint(i-1, j: j+1))
				let shouldAdd : Bool = (topLeftNeighbor.name != Names.Mushroom)
										&& (topRightNeightbor.name != Names.Mushroom)
										&& randBool(20)
				
				if shouldAdd {
            		let mushroom = Mushroom(imageNamed:"mushroom")
            		mushroom.size = Sizes.Mushroom
					mushroom.setScale(0.75)
					mushroom.name = Names.Mushroom
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
	
	private func createNewSpaceShip() -> SKSpriteNode {
		let scale : CGFloat = 0.25
		let x : CGFloat = size.width/2.0
		let y : CGFloat = Sizes.SpaceShip.height/2 + 20
		
		let spaceShip = SKSpriteNode(imageNamed:"Spaceship")
		spaceShip.name = Names.SpaceShip
		spaceShip.size = Sizes.SpaceShip
		spaceShip.position = CGPoint(x:x, y:y)

		return spaceShip
	}
	
	private func createNewCentipede() -> Centipede {
		let maxRows = Int(size.height / Sizes.Mushroom.height)
		let maxCols = Int(size.width / Sizes.Mushroom.width)
	
		let startPoint = positionToPoint(maxRows-2, j:maxCols/2)
		
		return Centipede(numSegments: kCentipedeNumNodes, startPoint: startPoint)
	}
	
	private func randBool(percentChance:UInt32) -> Bool {
		let rand = arc4random() % 100
		return rand < percentChance
	}
	
	private func fire(startPosition:CGPoint) {
		let bullet = SKShapeNode(rectOfSize: Sizes.Bullet)
		bullet.physicsBody = SKPhysicsBody(rectangleOfSize: Sizes.Bullet)
		bullet.physicsBody?.categoryBitMask = Categories.Bullet
		bullet.physicsBody?.contactTestBitMask = Categories.Mushroom | Categories.Segment
		bullet.physicsBody?.collisionBitMask = Categories.None
		bullet.fillColor = UIColor.purpleColor()
		bullet.position = startPosition
		
		let moveAction = SKAction.moveToY(size.height+Sizes.Bullet.height, duration: 2.0)
		let removeAction = SKAction.removeFromParent()
		let sequence = SKAction.sequence([moveAction])
		bullet.runAction(sequence)
		
		addChild(bullet)
	}
}
