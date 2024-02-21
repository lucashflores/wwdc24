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
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @ObservedObject var viewModel: GameViewModel = GameViewModel.getInstance()
    var scnView = SCNView()
    
    var stones: [SCNNode] = [SCNNode]()
    var traps: [SCNNode] = [SCNNode]()
    var cameraNode:SCNNode!
    var car: SCNNode!
    var roadLeft: SCNNode!
    var roadMiddle: SCNNode!
    var roadRight: SCNNode!
    var obstacles: SCNNode = SCNNode()
    var coins: SCNNode = SCNNode()
    var timer = Timer()
    var gameTime: Double = 0
    var obstacle1: SCNNode!
    var scene: SCNScene!
    
    var hudNode: SCNNode!
    var labelNode: SKLabelNode!
    var interval1: Double=2
    var score: Int = 0
    var paused = false
    
    var highScoreClosure: () -> Void = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCommandsNotifications()
        let sizeScnView = CGSize(width: 2250, height: 1405)
        
        scnView.frame = CGRect(origin: .zero, size: sizeScnView)

        scene = SCNScene(named: "main.scn")!
        cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)!
        
        car = scene.rootNode.childNode(withName: "car", recursively: true)!
        car.physicsBody?.type = .dynamic
        car.physicsBody?.isAffectedByGravity = false
//        car.physicsBody?.categoryBitMask = 3
//        car.physicsBody?.isAffectedByGravity = false
        
        var stone = scene.rootNode.childNode(withName: "stones", recursively: true)!
        var trap = scene.rootNode.childNode(withName: "trap", recursively: true)!
        
        for _ in 1...8 {
            stones.append(stone.clone())
        }
        
        for _ in 1...15 {
            traps.append(trap.clone())
        }
        
        roadLeft = scene.rootNode.childNode(withName: "road_left", recursively: true)!
        roadLeft.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: roadLeft))
        roadLeft.physicsBody?.categoryBitMask = 1
       
        roadMiddle = scene.rootNode.childNode(withName: "road_middle", recursively: true)!
        roadMiddle.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: roadMiddle))
        roadMiddle.physicsBody?.categoryBitMask = 1
        
        roadRight = scene.rootNode.childNode(withName: "road_right", recursively: true)!
        roadRight.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: roadRight))
        roadRight.physicsBody?.categoryBitMask = 1
        
        scene.rootNode.addChildNode(obstacles)
        scene.physicsWorld.contactDelegate=self
        scnView.scene = scene
        scnView.showsStatistics = true
        scnView.pointOfView?.camera?.zFar = 700
        scnView.backgroundColor = UIColor.black
        initHUD()
        updateHUD()
        
        view.addSubview(scnView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(interval1), target: self, selector: #selector(update4t(timer:)), userInfo: nil, repeats: true)
    }
 
    func moveCar(direction: moveCarDirection, twoTimes: Bool = false) {
        let carX = car.presentation.position.x.rounded()
        let carY = car.presentation.position.y
        print(carX)
        print(carY)
        if ((carX != -15 && carX != 0 && carX != 15) || carY > 5.5) {
            return
        }
        switch direction {
        case .right :
            if car.presentation.position.x.rounded() > -15 {
                
                if (twoTimes) {
//                    startActionCooldown(duration: 0.3)
                    car.runAction(SCNAction.moveBy(x: -15, y: 0, z: 0, duration: 0.15), completionHandler: nil)
                    car.runAction(SCNAction.moveBy(x: -15, y: 0, z: 0, duration: 0.15), completionHandler: nil)
                }
                else {
                    car.runAction(SCNAction.moveBy(x: -15, y: 0, z: 0, duration: 0.2), completionHandler: nil)
                }
                
            }
        case .left :
            if car.presentation.position.x.rounded() < 15 {
                
                if (twoTimes) {
//                    startActionCooldown(duration: 0.3)
                    car.runAction(SCNAction.moveBy(x: 15, y: 0, z: 0, duration: 0.15), completionHandler: nil)
                    car.runAction(SCNAction.moveBy(x: 15, y: 0, z: 0, duration: 0.15), completionHandler: nil)
                }
                else {
//                    startActionCooldown(duration: 0.2)
                    car.runAction(SCNAction.moveBy(x: 15, y: 0, z: 0, duration: 0.2), completionHandler: nil)
                }
                
            }
        case .up :
            print(car.presentation.position.y)
            if car.presentation.position.y < 5.5 {
//                startActionCooldown(duration: 1)
                let moveUp = SCNAction.moveBy(x: 0, y: 25, z: 0, duration: 0.5)
                moveUp.timingMode = SCNActionTimingMode.easeOut;
                let moveDown = SCNAction.moveBy(x: 0, y: -25, z: 0, duration: 0.5)
                moveDown.timingMode = SCNActionTimingMode.easeIn;
                let moveSequence = SCNAction.sequence([moveUp, moveDown])
                car.runAction(moveSequence, completionHandler: nil)
                
            }
            print("up")
        }
        
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
            gameTime += interval1
            let roadToSpawn = roads.allCases.randomElement()!
            let o4=obs(pos: SCNVector3(roadToSpawn.rawValue,7,-100), vel: SCNVector3(0,0,-150))
            obstacles.addChildNode(o4)
            updateHUD()
        }
        
    }
    
    func restartGame() {
        obstacles.removeFromParentNode()
        obstacles = SCNNode()
        scene.rootNode.addChildNode(obstacles)
        scene.isPaused=false
        paused=false
    }
    
    func configureCommandsNotifications() {
        func didPressRightArrowKey() {
            moveCar(direction: .right)
        }
        
        func didPressLeftArrowKey() {
            moveCar(direction: .left)
        }
        
        func didPressUpArrowKey() {
            moveCar(direction: .up)
        }
        
        func didStandInTheMiddle() {
            let carX = car.presentation.position.x.rounded()
            print(carX)
            if (carX == roads.roadLeft.rawValue) {
                moveCar(direction: .right)
            }
            else if (carX <= roads.roadRight.rawValue) {
                moveCar(direction: .left)
            }
        }
        
        func didStandInTheLeft() {
            let carX = car.presentation.position.x.rounded()
            print(carX)
            if (carX == roads.roadMiddle.rawValue) {
                moveCar(direction: .left)
            }
//            else if (carX == roads.roadRight.rawValue) {
//                moveCar(direction: .left, twoTimes: true)
//            }
        }
        
        func didStandInTheRight() {
            let carX = car.presentation.position.x.rounded()
            print(carX)
            if (carX == roads.roadMiddle.rawValue) {
                moveCar(direction: .right)
            }
//            else if (carX >= roads.roadLeft.rawValue) {
//                moveCar(direction: .right, twoTimes: true)
//            }
        }
        
        func didJumpInTheMiddle() {
            didStandInTheMiddle()
            moveCar(direction: .up)
        }
        
        func didJumpInTheLeft() {
            didStandInTheLeft()
            moveCar(direction: .up)
        }
        
        func didJumpInTheRight() {
            didStandInTheRight()
            moveCar(direction: .up)
        }
        
        func didCrouchInTheMiddle() {
            didStandInTheMiddle()
            moveCar(direction: .up)
        }
        
        func didCrouchInTheLeft() {
            didStandInTheLeft()
            moveCar(direction: .up)
        }
        
        func didCrouchInTheRight() {
            didStandInTheRight()
            moveCar(direction: .up)
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
        
        NotificationCenter.default.addObserver(forName: Notification.Name("didCrouchInTheLeft"), object: nil, queue: nil) { (notification) in
            didCrouchInTheLeft()
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("didCrouchInTheRight"), object: nil, queue: nil) { (notification) in
            didCrouchInTheRight()
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("didCrouchInTheMiddle"), object: nil, queue: nil) { (notification) in
            didCrouchInTheMiddle()
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("restartGame"), object: nil, queue: nil) { (notification) in
            self.viewModel.gameOver = false
            self.restartGame()
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if contact.nodeB.name == "obstacle" && contact.nodeA.name == "car" {
            print("game over",contact.nodeA.name!,contact.nodeB.name!)
            gameOver()
            //    contact.
        }
    }
    
    func rotLeft(a: [SCNNode], d: Int) -> [SCNNode] {
        let slice1 = a[..<d]
        let slice2 = a[d...]
        return Array(slice2) + Array(slice1)
    }

    func obs(pos:SCNVector3,vel:SCNVector3)->SCNNode{
        let chosenObs = Int.random(in: 1...3)
        var obstacle:SCNNode!
        if (chosenObs == 3) {
            obstacle = stones.first
            stones = rotLeft(a: stones, d: 1)
        }
        else {
            obstacle = traps.first
            traps = rotLeft(a: traps, d: 1)
        }
        obstacle.physicsBody = SCNPhysicsBody.init(type: SCNPhysicsBodyType.dynamic, shape: nil)
        obstacle.physicsBody?.categoryBitMask = 2
        obstacle.physicsBody?.contactTestBitMask = 3
        obstacle.physicsBody?.isAffectedByGravity = false
//        obstacle.name="obstacle"
        obstacle.physicsBody?.friction = 0
        obstacle.physicsBody?.rollingFriction = 0
        obstacle.position=pos
        obstacle.physicsBody?.velocity = vel
        
        return obstacle
        
    }
    
    func initHUD() {
        
        let skScene = SKScene(size: CGSize(width: 500, height: 100))
        skScene.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        
        labelNode = SKLabelNode(fontNamed: "Menlo-Bold")
        labelNode.fontSize = 48
        labelNode.position.y = 50
        labelNode.position.x = 250
        
        skScene.addChild(labelNode)
        
        let plane = SCNPlane(width: 5, height: 1)
        let material = SCNMaterial()
        material.lightingModel = SCNMaterial.LightingModel.constant
        material.isDoubleSided = true
        material.diffuse.contents = skScene
        plane.materials = [material]
        
        hudNode = SCNNode(geometry: plane)
        hudNode.name = "HUD"
        hudNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: 3.14159265)
        hudNode.position = SCNVector3(x: 0.0, y: 40.0, z: 35.0)
        scene.rootNode.addChildNode(hudNode)
    }
    
    func updateHUD() {
        score=Int(gameTime)/2
        labelNode.text = "score:\(score)"
        
    }
    
    func gameOver()  {
        scene.isPaused=true
        paused=true
        DispatchQueue.main.async {
            self.viewModel.score = self.score
            self.viewModel.gameOver = true
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

enum moveCarDirection {
    case right
    case left
    case up
}
