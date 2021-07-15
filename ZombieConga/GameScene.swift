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
    var lastTouchLocation: CGPoint = CGPoint.zero
    let zombieRotateRadiansPerSec:CGFloat = 4.0 * CGFloat.pi

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

    func rotate(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }

    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
    }

    func moveZombieToward(location: CGPoint) {
        let offset = location - zombie.position
        let direction = offset.normalized()
        velocity = direction * zombieMovePointsPerSec
    }

    func sceneTouched(touchLocation: CGPoint) {
        lastTouchLocation = touchLocation
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

        run(SKAction.repeatForever(
                SKAction.sequence([SKAction.run() { [weak self] in
                    self?.spawnEnemy()
                },
                    SKAction.wait(forDuration: 2.0)])))

        debugDrawPlayableArea()
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime

        if (zombie.position - lastTouchLocation).length() <= zombieMovePointsPerSec * CGFloat(dt) {
            velocity = CGPoint.zero
            zombie.position = lastTouchLocation
        } else {
            move(sprite: zombie, velocity: velocity)
            boundsCheckZombie()
            rotate(sprite: zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
        }
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

    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        let rand = CGFloat.random(in: (playableRect.minY + enemy.size.height/2) ... (playableRect.maxY - enemy.size.height/2))
        enemy.position = CGPoint(
                x: size.width + enemy.size.width/2,
                y: rand)
        addChild(enemy)
        let actionMove =
                SKAction.moveTo(x: -enemy.size.width/2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([actionMove, actionRemove]))
    }
}
