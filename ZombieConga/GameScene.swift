//
//  GameScene.swift
//  ZombieConga
//
//  Created by Evgenii Ryshkov on 04.07.2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    let zombie = SKSpriteNode(imageNamed: "zombie1")

    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        addChild(background)

        zombie.position = CGPoint(x: 400, y: 400)
        zombie.setScale(2)
        addChild(zombie)
    }
}
