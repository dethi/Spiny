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

struct PathGroup {
    let one: CGPath
    let two: CGPath
    let three: CGPath
    let four: CGPath
    
    func getPath() -> CGPath {
        switch (arc4random_uniform(4)) {
        case 0:
            return one
        case 1:
            return two
        case 2:
            return three
        default:
            return four
        }
    }
}

enum Color: Int {
    case Green = 0
    case Orange = 1
    case Red = 2
    case Blue = 3
}

enum SpinyState {
    case Game
    case GameEnded
    case Menu
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let whiteColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
    let darkGreyColor = UIColor(red: 0.301, green: 0.298, blue: 0.309, alpha: 1)
    let redColor = UIColor(red: 238, green: 90, blue: 79, alpha: 1)
    let orangeColor = UIColor(red: 245, green: 163, blue: 49, alpha: 1)
    let greenColor = UIColor(red: 137, green: 201, blue: 98, alpha: 1)
    let blueColor = UIColor(red: 97, green: 204, blue: 241, alpha: 1)
    
    var mainLayer: SKSpriteNode!
    var colorSelector: ColorSelectorNode!
    var scoreLabel: SKLabelNode!
    var paths: PathGroup!
    
    var menuLayer: SKSpriteNode!
    var playButton: SKSpriteNode!
    var bigColorSelector: SKSpriteNode!
    var gameCenterButton: SKSpriteNode!
    var highScoreLabel: SKLabelNode!
    
    var noMusicButton: SKSpriteNode!
    var musicButton: SKSpriteNode!
    
    var lastAddedTime = 0.0
    var blockInteraction = true
    var currentState = SpinyState.Menu
    
    var score: UInt = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    var highScore: UInt = 0 {
        didSet {
            highScoreLabel.text = "High Score: \(highScore)"
        }
    }
    
    var playMusic: Bool = true {
        didSet {
            if playMusic {
                noMusicButton.hidden = true
                musicButton.hidden = false
            } else {
                noMusicButton.hidden = false
                musicButton.hidden = true
            }
            
            NSUserDefaults.standardUserDefaults().setBool(playMusic, forKey: "playMusic")
            NSNotificationCenter.defaultCenter().postNotificationName(changeAudioSettingKey, object: nil)
        }
    }
    
    override func didMoveToView(view: SKView) {
        
        backgroundColor = darkGreyColor
        physicsWorld.gravity = CGVector.zeroVector
        physicsWorld.contactDelegate = self
        
        mainLayer = SKSpriteNode(color: UIColor.clearColor(), size: frame.size)
        mainLayer.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(mainLayer)
        
        // Setup the Color Selector
        colorSelector = ColorSelectorNode.newColorSelector()
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
        
        // Setup path structure
        paths = PathGroup(one: topPath.bezierPathByReversingPath().CGPath,
            two: rightPath.bezierPathByReversingPath().CGPath,
            three: bottomPath.bezierPathByReversingPath().CGPath,
            four: leftPath.bezierPathByReversingPath().CGPath)
        
        // Setup score
        scoreLabel = SKLabelNode(text: "0")
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 60)
        scoreLabel.fontName = "DINAlternate-Bold"
        scoreLabel.fontColor = whiteColor
        addChild(scoreLabel)
        
        // Setup menu
        menuLayer = SKSpriteNode(color: darkGreyColor, size: size)
        menuLayer.position = CGPoint(x: frame.midX, y: frame.midY)
        menuLayer.zPosition = 1.0
        addChild(menuLayer)
        
        bigColorSelector = SKSpriteNode(imageNamed: "BigColorSelector")
        menuLayer.addChild(bigColorSelector)
        
        playButton = SKSpriteNode(imageNamed: "Play")
        menuLayer.addChild(playButton)
        
        gameCenterButton = SKSpriteNode(imageNamed: "Leaderboard")
        gameCenterButton.position = CGPoint(x: menuLayer.size.width * 0.5 - gameCenterButton.size.width,
            y: -menuLayer.size.height * 0.5 + gameCenterButton.size.height)
        menuLayer.addChild(gameCenterButton)
        
        musicButton = SKSpriteNode(imageNamed: "Music")
        noMusicButton = SKSpriteNode(imageNamed: "NoMusic")
        let musicButtonPosition = CGPoint(x: -menuLayer.size.width * 0.5 + musicButton.size.width,
            y: -menuLayer.size.height * 0.5 + musicButton.size.height)
        musicButton.position = musicButtonPosition
        noMusicButton.position = musicButtonPosition
        menuLayer.addChild(musicButton)
        menuLayer.addChild(noMusicButton)
        
        highScoreLabel = SKLabelNode(fontNamed: "DINAlternate-Bold ")
        highScoreLabel.position = CGPoint(x: 0, y: -bigColorSelector.size.height * 0.7)
        highScoreLabel.fontColor = whiteColor
        highScoreLabel.fontSize = 24
        menuLayer.addChild(highScoreLabel)
        
        let titleLabel = SKLabelNode(text: "Spiny")
        titleLabel.position = CGPoint(x: 0, y: bigColorSelector.size.height * 0.75)
        titleLabel.fontColor = whiteColor
        titleLabel.fontSize = 50
        titleLabel.fontName = "System-Regular"
        menuLayer.addChild(titleLabel)
        
        highScore = NSUserDefaults.standardUserDefaults().valueForKey("highScore") as! UInt
        playMusic = NSUserDefaults.standardUserDefaults().boolForKey("playMusic")
    }
    
    func newGame() {
        // Clean game
        mainLayer.enumerateChildNodesWithName("circle", usingBlock: { (node, end) -> Void in
            node.removeFromParent()
        })
        
        // Rotate main layer
        let rotate = SKAction.rotateByAngle(CGFloat(M_PI), duration: 60)
        mainLayer.runAction(SKAction.repeatActionForever(rotate), withKey: "rotation")
        
        let startGame = SKAction.sequence([
            SKAction.runBlock { self.scoreLabel.text = "Go !" },
            SKAction.waitForDuration(2),
            SKAction.runBlock { self.score = 0 }
            ])
        runAction(startGame)
        
        lastAddedTime = 0.0
        currentState = .Game
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch in (touches as! Set<UITouch>) {
            switch (currentState) {
            case .Menu:
                let location = touch.locationInNode(menuLayer)
                if playButton.containsPoint(location) {
                    playButton.runAction(SKAction.rotateByAngle(CGFloat(M_PI * 2), duration: 0.5))
                    bigColorSelector.runAction(SKAction.rotateByAngle(-CGFloat(M_PI * 2), duration: 0.5))
                    
                    menuLayer.runAction(SKAction.sequence([
                        SKAction.waitForDuration(0.5),
                        SKAction.fadeOutWithDuration(1)]))
                    newGame()
                } else if gameCenterButton.containsPoint(location) {
                    let pulseOut = SKAction.scaleTo(1.15, duration: 0.15)
                    let pulseIn = SKAction.scaleTo(1.0, duration: 0.15)
                    let showGameCenter = SKAction.runBlock({ () -> Void in
                        NSNotificationCenter.defaultCenter().postNotificationName(showGameCenterKey, object: nil)
                    })
                    
                    gameCenterButton.runAction(SKAction.sequence([pulseOut, pulseIn, showGameCenter]))
                } else if musicButton.containsPoint(location) {
                    playMusic = !playMusic
                }
            case .Game:
                let location = touch.locationInNode(self)
                colorSelector.rotate((location.x > frame.midX) ? .Right : .Left)
            case .GameEnded:
                if !blockInteraction {
                    blockInteraction = true
                    currentState = .Menu
                    scoreLabel.removeAllActions()
                    menuLayer.runAction(SKAction.fadeInWithDuration(0.7))
                    NSNotificationCenter.defaultCenter().postNotificationName(canDisplayAdsKey, object: nil)
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        if currentState == .Game {
            let elapsedTime = currentTime - lastAddedTime
            
            if (score < 10) {
                if elapsedTime > 1.5 {
                    addNewCircle(100 + CGFloat(score))
                    mainLayer.actionForKey("rotation")?.speed += 0.07
                    lastAddedTime = currentTime
                }
            } else if (score < 20) {
                if elapsedTime > (1.5 - Double(score - 10) / 40) {
                    addNewCircle(110)
                    mainLayer.actionForKey("rotation")?.speed += 0.15
                    lastAddedTime = currentTime
                }
            } else {
                if elapsedTime > 1.1 {
                    addNewCircle(110 + CGFloat(score) / 15)
                    lastAddedTime = currentTime
                }
            }
        }     
    }
    
    func addNewCircle(speed: CGFloat) {
        let circle = CircleNode.newCircleWithRandomColor()
        circle.followsPath(paths.getPath(), speed: speed)
        mainLayer.addChild(circle)
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
            if let circle = bodyB.node as? CircleNode {
                let location = mainLayer.convertPoint(contact.contactPoint, fromNode: self)
                
                if circle.circleColor == colorSelector.colorAtPosition(location) {
                    ++score
                    circle.willArrive()
                } else {
                    // GameOver
                    mainLayer.enumerateChildNodesWithName("circle", usingBlock: { (node, end) -> Void in
                        node.removeAllActions()
                    })
                    mainLayer.removeAllActions()
                    removeAllActions()
                    
                    let alpha = ceil(mainLayer.zRotation / CGFloat(M_PI_2)) * CGFloat(M_PI_2)
                    mainLayer.runAction(SKAction.sequence([
                        SKAction.rotateToAngle(alpha, duration: 1.2),
                        SKAction.runBlock { self.blockInteraction = false }
                    ]))
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(saveScoreKey, object: nil)
                    currentState = .GameEnded
                    
                    let pulseOut = SKAction.scaleTo(1.2, duration: 0.7)
                    let pulseIn = SKAction.scaleTo(1.0, duration: 0.6)
                    
                    scoreLabel.runAction(SKAction.repeatActionForever(SKAction.sequence([pulseOut, pulseIn])))
                }
            }
        }
    }
}
