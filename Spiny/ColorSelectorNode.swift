//
//  ColorSelectorNode.swift
//  Spiny
//
//  Created by Thibault Deutsch on 13/04/15.
//  Copyright (c) 2015 Thibault Deutsch. All rights reserved.
//

import Foundation
import SpriteKit

enum RotationDirection: Int {
    case Right = -1
    case Left = 1
}

class ColorSelectorNode: SKSpriteNode {
    private let rightRotation = SKAction.rotateByAngle(-CGFloat(M_PI_2), duration: 0.2)
    private let leftRotation = SKAction.rotateByAngle(CGFloat(M_PI_2), duration: 0.2)
    
    private var currentTopColor: Int = 0
    
    class func newColorSelector() -> ColorSelectorNode {
        let newNode = ColorSelectorNode(imageNamed: "ColorSelector")
        newNode.physicsBody = SKPhysicsBody(circleOfRadius: newNode.size.width * 0.5)
        newNode.physicsBody?.dynamic = false
        newNode.physicsBody?.categoryBitMask = kSelectorCategory
        newNode.physicsBody?.contactTestBitMask = kCircleCategory
        
        return newNode
    }
    
    func rotate(direction: RotationDirection) {
        switch (direction) {
        case .Right:
            runAction(rightRotation)
        case .Left:
            runAction(leftRotation)
        }
        
        currentTopColor = mod(currentTopColor + direction.rawValue, 4)
    }
    
    func colorAtPosition(position: CGPoint) -> Color {
        let delta = size.height * 0.4
        
        var color = currentTopColor
        if position.y < -delta { // bottom
            color += 2
        } else if position.x > delta { // right
            ++color
        } else if position.x < -delta { // left
            --color
        }
        
        switch (mod(color, 4)) {
        case 0:
            return Color.Green
        case 1:
            return Color.Orange
        case 2:
            return Color.Red
        default:
            return Color.Blue
        }
    }
}