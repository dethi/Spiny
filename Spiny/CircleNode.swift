//
//  CircleNode.swift
//  Spiny
//
//  Created by Thibault Deutsch on 11/04/15.
//  Copyright (c) 2015 Thibault Deutsch. All rights reserved.
//

import Foundation
import SpriteKit

class CircleNode: SKSpriteNode {
    private let removeCircle = SKAction.sequence([
        SKAction.fadeOutWithDuration(0.1),
        SKAction.removeFromParent()
    ])
    
    var circleColor: Color?
    
    class func newCircleWithRandomColor() -> CircleNode {
        var color: Color
        switch (arc4random_uniform(4)) {
        case 0:
            color = .Green
        case 1:
            color = .Orange
        case 2:
            color = .Red
        default:
            color = .Blue
        }
        
        var newNode: CircleNode
        switch (color) {
        case .Green:
            newNode = CircleNode(imageNamed: "GreenCircle")
        case .Orange:
            newNode = CircleNode(imageNamed: "OrangeCircle")
        case .Red:
            newNode = CircleNode(imageNamed: "RedCircle")
        case .Blue:
            newNode = CircleNode(imageNamed: "BlueCircle")
        }
        
        newNode.name = "circle"
        newNode.circleColor = color
        newNode.physicsBody = SKPhysicsBody(circleOfRadius: newNode.size.width * 0.5)
        newNode.physicsBody?.categoryBitMask = kCircleCategory
        newNode.physicsBody?.collisionBitMask = 0
        
        return newNode
    }
    
    func followsPath(path: CGPath, speed: CGFloat){
        let action = SKAction.followPath(path, speed: 50)
        runAction(action)
    }
    
    func willArrive() {
        removeAllActions()
        runAction(removeCircle)
    }
}