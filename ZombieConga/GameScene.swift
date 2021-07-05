//
//  GameScene.swift
//  ZombieConga
//
//  Created by Evgenii Ryshkov on 04.07.2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(background)
    }
}
