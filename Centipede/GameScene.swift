//
//  GameScene.swift
//  Centipede
//
//  Created by Joey Jiron Jr on 11/10/14.
//  Copyright (c) 2014 ccc. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
	
	
	let kShipSize = CGSize(width:45, height:45)
	let kBulletSize = CGSize(width:5, height:10)

	struct SceneObjNames {
		let kCentipedeNode = "cent-node"
	}
	
	private var mSpaceShip : SKSpriteNode!
	private var mCentipede : SKNode!
	
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
		setupSpaceShip()
		
		mCentipede = createCentipede()
		addChild(mCentipede)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
		fire(mSpaceShip.position)
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
	
	//MARK: scene setup
	
	private func setupSpaceShip() {
		let scale : CGFloat = 0.25
		let x : CGFloat = size.width/2.0
		let y : CGFloat = kShipSize.height/2 + 20
		
		mSpaceShip = SKSpriteNode(imageNamed:"Spaceship")
		mSpaceShip.size = kShipSize
		mSpaceShip.position = CGPoint(x:x, y:y)
		addChild(mSpaceShip)
	}
	
	private func createCentipede() -> SKShapeNode {
		let radius : CGFloat = 10
		let centipede = SKShapeNode(circleOfRadius:radius)
		centipede.position = CGPoint(x:radius/2, y:size.height+radius/2)
		centipede.fillColor = UIColor.greenColor()
		return centipede
	}
	
	private func fire(startPosition:CGPoint) {
		let bullet = SKShapeNode(rectOfSize: kBulletSize)
		bullet.fillColor = UIColor.purpleColor()
		bullet.position = startPosition
		
		let moveAction = SKAction.moveToY(size.height+kBulletSize.height, duration: 2.0)
		let removeAction = SKAction.removeFromParent()
		SKAction.sequence([moveAction, removeAction])
		bullet.runAction(moveAction)
		
		addChild(bullet)
	}
}
