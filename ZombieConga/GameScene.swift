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
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480
    var velocity = CGPoint.zero
    let playableRect: CGRect

    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 19.5/9
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight) / 2
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)

        super.init(size: size)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }

    func rotate(sprite: SKSpriteNode, direction: CGPoint) {
        sprite.zRotation = CGFloat(atan2(Double(direction.y), Double(direction.x)))
    }

    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt), y: velocity.y * CGFloat(dt))
        print("amnt to move \(amountToMove)")

        sprite.position = CGPoint(x: sprite.position.x + amountToMove.x, y: sprite.position.y + amountToMove.y)
    }

    func moveZombieToward(location: CGPoint) {
        let offset = CGPoint(x: location.x - zombie.position.x, y: location.y - zombie.position.y)

        let length = sqrt(offset.x * offset.x + offset.y*offset.y)

        let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length))
        velocity = CGPoint(x: direction.x * zombieMovePointsPerSec, y: direction.y * zombieMovePointsPerSec)
    }

    func sceneTouched(touchLocation: CGPoint) {
        moveZombieToward(location: touchLocation)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        addChild(background)

        zombie.position = CGPoint(x: 400, y: 400)
        addChild(zombie)
        debugDrawPlayableArea()
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        print("\(dt*1000) ms since last update")

        move(sprite: zombie, velocity: velocity)
        boundsCheckZombie()
        rotate(sprite: zombie, direction: velocity)
    }

    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: 0, y: playableRect.minY)
        let topRight = CGPoint(x: size.width, y: playableRect.maxY)

        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }

        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }

        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }

        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }

    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(playableRect)
        shape.path = path
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4
        addChild(shape)
    }
}
