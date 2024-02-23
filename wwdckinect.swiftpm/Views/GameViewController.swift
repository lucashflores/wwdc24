//
//  File.swift
//  
//
//  Created by Lucas Flores on 08/02/24.
//

import Foundation
import UIKit
import SceneKit
import Combine
import QuartzCore
import SceneKit
import SpriteKit
import CoreData
import SwiftUI

class GameViewController: UIViewController, SCNPhysicsContactDelegate {
    @ObservedObject var viewModel: GameViewModel = GameViewModel.getInstance()
    var scnView = SCNView()
    var cameraNode:SCNNode!
    var car: SCNNode!
    var roadLeft: SCNNode!
    var roadMiddle: SCNNode!
    var roadRight: SCNNode!
    var trap: SCNNode!
    var coin: SCNNode!
    var tree: SCNNode!
    var stones: SCNNode!
    var items: SCNNode = SCNNode()
    var timer = Timer()
    var scene: SCNScene!
    var interval1: Double = 2
    var paused = false
    var isCarRunningAction: Bool = false
    
    var highScoreClosure: () -> Void = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCommandsNotifications()
        let sizeScnView = CGSize(width: 2250, height: 1405)
        
        scnView.frame = CGRect(origin: .zero, size: sizeScnView)

        scene = SCNScene(named: "main.scn")!
        cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)!
        
        car = scene.rootNode.childNode(withName: "car", recursively: true)!
        car.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: car))
        car.physicsBody?.type = .dynamic
        car.physicsBody?.categoryBitMask = 3
        car.physicsBody?.collisionBitMask = 0
        car.physicsBody?.isAffectedByGravity = false
        
        self.stones = scene.rootNode.childNode(withName: "stones", recursively: true)!
        self.trap = scene.rootNode.childNode(withName: "trap", recursively: true)!
        self.coin = scene.rootNode.childNode(withName: "coin", recursively: true)!
        self.tree = scene.rootNode.childNode(withName: "tree", recursively: true)!
    
        roadLeft = scene.rootNode.childNode(withName: "road_left", recursively: true)!
        roadLeft.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: roadLeft))
        roadLeft.physicsBody?.categoryBitMask = 1
       
        roadMiddle = scene.rootNode.childNode(withName: "road_middle", recursively: true)!
        roadMiddle.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: roadMiddle))
        roadMiddle.physicsBody?.categoryBitMask = 1
        
        roadRight = scene.rootNode.childNode(withName: "road_right", recursively: true)!
        roadRight.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: roadRight))
        roadRight.physicsBody?.categoryBitMask = 1
        
        scene.background.contents = [UIImage(named: "Right.bmp")!, UIImage(named: "Left.bmp")!, UIImage(named: "Top.bmp")!, UIImage(named: "Bottom.bmp")!, UIImage(named: "Back.bmp")!, UIImage(named: "Front.bmp")!];
        scene.rootNode.addChildNode(items)
        scene.physicsWorld.contactDelegate=self
        scnView.scene = scene
        scnView.showsStatistics = true
        scnView.pointOfView?.camera?.zFar = 700
        scnView.backgroundColor = UIColor.black
        view.addSubview(scnView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(interval1), target: self, selector: #selector(update4t(timer:)), userInfo: nil, repeats: true)
    }
 
    func moveCar(move: CarMove, twoTimes: Bool = false) {
        let carX = car.presentation.position.x.rounded()
        let carY = car.presentation.position.y
        let carZ = car.presentation.position.z
        print(carX)
        print(carY)
        if isCarRunningAction {
            return
        }
        self.isCarRunningAction = true
        switch move {
        case .midRoad:
            car.runAction(SCNAction.move(to: SCNVector3(x: 0, y: carY, z: carZ), duration: 0.2)) {
                self.isCarRunningAction = false
            }
        case .rightRoad:
            car.runAction(SCNAction.move(to: SCNVector3(x: -15, y: carY, z: carZ), duration: 0.2)) {
                self.isCarRunningAction = false
            }
        case .leftRoad:
            car.runAction(SCNAction.move(to: SCNVector3(x: 15, y: carY, z: carZ), duration: 0.2)) {
                self.isCarRunningAction = false
            }
        case .up :
                let moveUp = SCNAction.moveBy(x: 0, y: 22, z: 0, duration: 0.5)
                moveUp.timingMode = SCNActionTimingMode.easeOut;
                let moveDown = SCNAction.moveBy(x: 0, y: -22, z: 0, duration: 0.5)
                moveDown.timingMode = SCNActionTimingMode.easeIn;
                let moveSequence = SCNAction.sequence([moveUp, moveDown])
                car.runAction(moveSequence) {
                    self.isCarRunningAction = false
                }
                
        }
            print("up")
        
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    @objc func update4t(timer:Timer) -> Void {
        if !paused {
            DispatchQueue.main.async {
                self.viewModel.score += 1
            }
            items.childNodes.forEach {node in
                if (node.presentation.position.z < -900) {
                    node.removeFromParentNode()
                }
            }
            let itemToSpawn = Int.random(in: 1...10)
            let roadToSpawn = roads.allCases.randomElement()!
            let pos: SCNVector3 = SCNVector3(roadToSpawn.rawValue,5,-200)
            let vel: SCNVector3 = SCNVector3(0,0,-150)
            let item: SCNNode
            if (itemToSpawn <= 1) {
                item = coin(pos: pos, vel: vel)
            }
            else if (itemToSpawn <= 4) {
                item = obs(pos: pos, vel: vel, type: .stones)
            }
            else {
                item = obs(pos: pos, vel: vel, type: .trap  )
            }
            items.addChildNode(item)
        }
        
    }
    
    func restartGame() {
        items.removeFromParentNode()
        items = SCNNode()
        scene.rootNode.addChildNode(items)
        moveCar(move: .midRoad)
        self.viewModel.score = 0
        scene.isPaused=false
        paused=false
    }
    
    
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if contact.nodeB.name == "obstacle" && contact.nodeA.name == "car" {
            print("game over",contact.nodeA.name!,contact.nodeB.name!)
            gameOver()
        }
        else if contact.nodeB.name == "spawnedCoin" && contact.nodeA.name == "car" {
            contact.nodeB.removeFromParentNode()
            DispatchQueue.main.async {
                self.viewModel.coins += 1
            }
        }
    }
    
    func rotLeft(a: [SCNNode], d: Int) -> [SCNNode] {
        let slice1 = a[..<d]
        let slice2 = a[d...]
        return Array(slice2) + Array(slice1)
    }
    
    func spawnTreesBatch() {
        
    }
    
    func tree(pos: SCNVector3, vel: SCNVector3) -> SCNNode {
        let newTree: SCNNode = self.coin.clone()
        newTree.physicsBody = SCNPhysicsBody.init(type: SCNPhysicsBodyType.dynamic, shape: nil)
        newTree.physicsBody?.categoryBitMask = 2
        newTree.physicsBody?.contactTestBitMask = 3
        newTree.physicsBody?.isAffectedByGravity = false
        newTree.name = "spawnedTree"
        newTree.physicsBody?.friction = 0
        newTree.physicsBody?.rollingFriction = 0
        newTree.position = pos
        newTree.physicsBody?.velocity = vel
        return newTree
    }
    
    func coin(pos: SCNVector3, vel: SCNVector3) -> SCNNode {
        let newCoin: SCNNode = self.coin.clone()
        newCoin.physicsBody = SCNPhysicsBody.init(type: SCNPhysicsBodyType.dynamic, shape: nil)
        newCoin.physicsBody?.categoryBitMask = 2
        newCoin.physicsBody?.contactTestBitMask = 3
        newCoin.physicsBody?.isAffectedByGravity = false
        newCoin.name="spawnedCoin"
        newCoin.physicsBody?.friction = 0
        newCoin.physicsBody?.rollingFriction = 0
        newCoin.position=pos
        newCoin.physicsBody?.velocity = vel
        return newCoin
    }

    func obs(pos: SCNVector3, vel: SCNVector3, type: ObstacleType)->SCNNode{
        var obstacle: SCNNode!
        if (type == .stones) {
            obstacle = self.stones.clone()
        }
        else if (type == .trap) {
            obstacle = self.trap.clone()
        }
        obstacle.physicsBody = SCNPhysicsBody.init(type: SCNPhysicsBodyType.dynamic, shape: nil)
        obstacle.physicsBody?.categoryBitMask = 2
        obstacle.physicsBody?.contactTestBitMask = 3
        obstacle.physicsBody?.isAffectedByGravity = false
        obstacle.name="obstacle"
        obstacle.physicsBody?.friction = 0
        obstacle.physicsBody?.rollingFriction = 0
        obstacle.position=pos
        obstacle.physicsBody?.velocity = vel
        
        return obstacle
        
    }
    
    func gameOver()  {
        scene.isPaused=true
        paused=true
        DispatchQueue.main.async {
            self.viewModel.gameOver = true
        }
        
    }
}

extension GameViewController {
    func configureCommandsNotifications() {
        func didPressRightArrowKey() {
            let carX = car.presentation.position.x.rounded()
            if (carX == roads.roadLeft.rawValue) {
                moveCar(move: .midRoad)
            }
            else {
                moveCar(move: .rightRoad)
            }
        }
        
        func didPressLeftArrowKey() {
            let carX = car.presentation.position.x.rounded()
            if (carX == roads.roadRight.rawValue) {
                moveCar(move: .midRoad)
            }
            else {
                moveCar(move: .leftRoad)
            }
        }
        
        func didPressUpArrowKey() {
            moveCar(move: .up)
        }
        
        func didStandInTheMiddle() {
            moveCar(move: .midRoad)
        }
        
        func didStandInTheLeft() {
            moveCar(move: .leftRoad)
        }
        
        func didStandInTheRight() {
            moveCar(move: .rightRoad)
        }
        
        func didJumpInTheMiddle() {
            moveCar(move: .up)
        }
        
        func didJumpInTheLeft() {
            moveCar(move: .up)
        }
        
        func didJumpInTheRight() {
            moveCar(move: .up)
        }
        
        
        NotificationCenter.default.addObserver(forName: Notification.Name("didPressRightArrowKey"), object: nil, queue: nil) { (notification) in
            print("arrowKey")
            didPressRightArrowKey()
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("didPressLeftArrowKey"), object: nil, queue: nil) { (notification) in
            didPressLeftArrowKey()
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("didPressUpArrowKey"), object: nil, queue: nil) { (notification) in
            didPressUpArrowKey()
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("didStandInTheLeft"), object: nil, queue: nil) { (notification) in
            didStandInTheLeft()
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("didStandInTheRight"), object: nil, queue: nil) { (notification) in
            didStandInTheRight()
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("didStandInTheMiddle"), object: nil, queue: nil) { (notification) in
            didStandInTheMiddle()
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("didJumpInTheLeft"), object: nil, queue: nil) { (notification) in
            didJumpInTheLeft()
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("didJumpInTheRight"), object: nil, queue: nil) { (notification) in
            didJumpInTheRight()
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("didJumpInTheMiddle"), object: nil, queue: nil) { (notification) in
            didJumpInTheMiddle()
        }
        
        
        NotificationCenter.default.addObserver(forName: Notification.Name("restartGame"), object: nil, queue: nil) { (notification) in
            self.viewModel.gameOver = false
            self.restartGame()
        }
    }
}


struct GameViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = GameViewController
    private let gameViewController = GameViewController()
    
    func makeUIViewController(context: Context) -> GameViewController {
        gameViewController
    }
    
    func updateUIViewController(_ uiViewController: GameViewController, context: Context) {
        
    }
}

enum ObstacleType: String, CaseIterable {
    case stones = "stones"
    case trap = "trap"
}


enum roads: Float, CaseIterable {
    case roadLeft = 15
    case roadMiddle = 0
    case roadRight = -15
}

enum CarMove {
    case midRoad
    case leftRoad
    case rightRoad
    case up
}
