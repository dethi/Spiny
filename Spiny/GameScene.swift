//
//  GameScene.swift
//  Spiny
//
//  Created by Thibault Deutsch on 10/04/15.
//  Copyright (c) 2015 Thibault Deutsch. All rights reserved.
//

import SpriteKit

let kSelectorCategory: UInt32   = 0x1 << 0
let kCircleCategory: UInt32     = 0x1 << 1

class GameScene: SKScene, SKPhysicsContactDelegate {
    let whiteColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1)
    let redColor = UIColor(red: 238, green: 90, blue: 79, alpha: 1)
    let orangeColor = UIColor(red: 245, green: 163, blue: 49, alpha: 1)
    let greenColor = UIColor(red: 137, green: 201, blue: 98, alpha: 1)
    let blueColor = UIColor(red: 97, green: 204, blue: 241, alpha: 1)
    
    var mainLayer: SKSpriteNode!
    var colorSelector: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    let rightRotation = SKAction.rotateByAngle(-CGFloat(M_PI_2), duration: 0.2)
    let leftRotation = SKAction.rotateByAngle(CGFloat(M_PI_2), duration: 0.2)
    let playRotateSound = SKAction.playSoundFileNamed("turn.caf", waitForCompletion: false)
    
    var score: UInt = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    override func didMoveToView(view: SKView) {
        
        backgroundColor = UIColor(red:0.301, green:0.298, blue:0.309, alpha:1)
        physicsWorld.gravity = CGVector.zeroVector
        physicsWorld.contactDelegate = self
        
        mainLayer = SKSpriteNode(color: UIColor.clearColor(), size: frame.size)
        mainLayer.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(mainLayer)
        
        // Setup the Color Selector
        colorSelector = SKSpriteNode(imageNamed: "ColorSelector")
        colorSelector.physicsBody = SKPhysicsBody(circleOfRadius: colorSelector.size.width * 0.5)
        colorSelector.physicsBody?.dynamic = false
        colorSelector.physicsBody?.categoryBitMask = kSelectorCategory
        colorSelector.physicsBody?.contactTestBitMask = kCircleCategory
        mainLayer.addChild(colorSelector)
        
        // Setup the Path
        let lineWidth = CGFloat(6)
        let pathLenght = CGFloat(size.height * 0.6)
        let circleRadius = CGFloat(70)
        let delta = CGFloat(10)
        let alpha = atan(((colorSelector.size.height + 20) * 0.5 - delta) / circleRadius)
        
        var circleCenter: CGPoint
        
        // Top path
        circleCenter = CGPoint(x: circleRadius, y: delta)
        
        let topPath = UIBezierPath()
        topPath.addArcWithCenter(circleCenter, radius: circleRadius, startAngle: CGFloat(M_PI) - alpha, endAngle: 0, clockwise: false)
        topPath.addLineToPoint(CGPoint(x: circleCenter.x + circleRadius, y: circleCenter.y - pathLenght))
        
        let topPathNode = SKShapeNode(path: topPath.CGPath)
        topPathNode.strokeColor = whiteColor
        topPathNode.lineCap = kCGLineCapRound
        topPathNode.lineWidth = lineWidth
        mainLayer.addChild(topPathNode)
        
        // Bottom path
        circleCenter = CGPoint(x: -circleRadius, y: -delta)
        
        let bottomPath = UIBezierPath()
        bottomPath.addArcWithCenter(circleCenter, radius: circleRadius, startAngle: 0 - alpha, endAngle: -CGFloat(M_PI), clockwise: false)
        bottomPath.addLineToPoint(CGPoint(x: circleCenter.x - circleRadius, y: circleCenter.y + pathLenght))
        
        let bottomPathNode = SKShapeNode(path: bottomPath.CGPath)
        bottomPathNode.strokeColor = whiteColor
        bottomPathNode.lineCap = kCGLineCapRound
        bottomPathNode.lineWidth = lineWidth
        mainLayer.addChild(bottomPathNode)
        
        // Right path
        circleCenter = CGPoint(x: delta, y: -circleRadius)
        
        let rightPath = UIBezierPath()
        rightPath.addArcWithCenter(circleCenter, radius: circleRadius, startAngle: CGFloat(M_PI_2) - alpha, endAngle: -CGFloat(M_PI_2), clockwise: false)
        rightPath.addLineToPoint(CGPoint(x: circleCenter.x - pathLenght, y: circleCenter.y - circleRadius))
        
        let rightPathNode = SKShapeNode(path: rightPath.CGPath)
        rightPathNode.strokeColor = whiteColor
        rightPathNode.lineCap = kCGLineCapRound
        rightPathNode.lineWidth = lineWidth
        mainLayer.addChild(rightPathNode)
        
        // Left path
        circleCenter = CGPoint(x: -delta, y: circleRadius)
        
        let leftPath = UIBezierPath()
        leftPath.addArcWithCenter(circleCenter, radius: circleRadius, startAngle: -CGFloat(M_PI_2) - alpha, endAngle: CGFloat(M_PI_2), clockwise: false)
        leftPath.addLineToPoint(CGPoint(x: circleCenter.x + pathLenght, y: circleCenter.y + circleRadius))
        
        let leftPathNode = SKShapeNode(path: leftPath.CGPath)
        leftPathNode.strokeColor = whiteColor
        leftPathNode.lineCap = kCGLineCapRound
        leftPathNode.lineWidth = lineWidth
        mainLayer.addChild(leftPathNode)
        
        // Rotate main layer
        let rotate = SKAction.rotateByAngle(CGFloat(M_PI), duration: 40)
        mainLayer.runAction(SKAction.repeatActionForever(rotate))
        
        // Setup score
        scoreLabel = SKLabelNode(text: "0")
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 60)
        scoreLabel.fontName = "DIN Alternate"
        scoreLabel.fontColor = whiteColor
        addChild(scoreLabel)
        
        // Test
        let circle = SKSpriteNode(imageNamed: "OrangeCircle")
        circle.physicsBody = SKPhysicsBody(circleOfRadius: circle.size.width * 0.5)
        circle.physicsBody?.categoryBitMask = kCircleCategory
        circle.physicsBody?.collisionBitMask = 0
        mainLayer.addChild(circle)
        
        let action = SKAction.followPath(topPath.bezierPathByReversingPath().CGPath, speed: 50)
        circle.runAction(action)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            
            colorSelector.runAction((location.x > frame.midX) ?
                rightRotation : leftRotation)
            colorSelector.runAction(playRotateSound)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func didBeginContact(contact: SKPhysicsContact) {        
        var bodyA: SKPhysicsBody
        var bodyB: SKPhysicsBody
        
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
            bodyA = contact.bodyA
            bodyB = contact.bodyB
        } else {
            bodyA = contact.bodyB
            bodyB = contact.bodyA
        }
        
        if (bodyA.categoryBitMask == kSelectorCategory && bodyB.categoryBitMask == kCircleCategory) {
            let removeCircle = SKAction.sequence([SKAction.fadeOutWithDuration(0.1), SKAction.removeFromParent()])
            bodyB.node?.removeAllActions()
            bodyB.node?.runAction(removeCircle)
        }
    }
}
