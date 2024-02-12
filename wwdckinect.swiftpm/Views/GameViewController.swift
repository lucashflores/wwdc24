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

class GameViewController: UIViewController,SCNPhysicsContactDelegate {
    
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var scnView = SCNView()
    
    var cameraNode:SCNNode!
    var car: SCNNode!
    var roadLeft: SCNNode!
    var roadMiddle: SCNNode!
    var roadRight: SCNNode!
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
//        let sizeScnView = CGSize(width: 1330, height: 1000)
        let sizeScnView = CGSize(width: 2250, height: 1405)
        let centerView = CGPoint(x: CGRectGetMidX(self.view.frame) - sizeScnView.width/2, y: CGRectGetMidY(self.view.frame) - sizeScnView.height/2)
        scnView.frame = CGRect(origin: .zero, size: sizeScnView)

        scene = SCNScene(named: "sedanSportsScn.scn")!
        cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)!
        
        car = scene.rootNode.childNode(withName: "car", recursively: true)!
//        let carGeometry = SCNBox(width: CGFloat(1.3*car.simdScale.x), height: CGFloat(0.733*car.simdScale.y), length: CGFloat(2.56*car.simdScale.z), chamferRadius: 0.2)
        car.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: car))
//        car.physicsBody?.isAffectedByGravity = true
//        car.physicsBody?.collisionBitMask = 2
        car.physicsBody?.categoryBitMask = 3
        car.name = "car"
        
        
        
        roadLeft = scene.rootNode.childNode(withName: "road_left", recursively: true)!
        roadLeft.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: roadLeft))
        roadLeft.physicsBody?.categoryBitMask = 1
       
        roadMiddle = scene.rootNode.childNode(withName: "road_middle", recursively: true)!
        roadMiddle.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: roadMiddle))
        roadMiddle.physicsBody?.categoryBitMask = 1
        
        roadRight = scene.rootNode.childNode(withName: "road_right", recursively: true)!
        roadRight.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: roadRight))
        roadRight.physicsBody?.categoryBitMask = 1
        
        scene.physicsWorld.contactDelegate=self
        scnView.scene = scene
//        initialObs()
//        scnView.allowsCameraControl = true
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
 
    func moveCar(direction: moveCarDirection){
        switch direction {
        case .right :
            if car.presentation.position.x.rounded() > -15 {
                car.runAction(SCNAction.moveBy(x: -15, y: 0, z: 0, duration: 0.2), completionHandler: nil)
            }
        case .left :
            if car.presentation.position.x.rounded() < 15 {
                car.runAction(SCNAction.moveBy(x: 15, y: 0, z: 0, duration: 0.2), completionHandler: nil)
            }
        case .up :
            print(car.presentation.position.y)
            if car.presentation.position.y < 5.5 {
    
                let moveUp = SCNAction.moveBy(x: 0, y: 25, z: 0, duration: 0.5)
                moveUp.timingMode = SCNActionTimingMode.easeOut;
                print(car.presentation.position.y)
                let moveDown = SCNAction.moveBy(x: 0, y: -25, z: 0, duration: 0.5)
                moveDown.timingMode = SCNActionTimingMode.easeIn;
                let moveSequence = SCNAction.sequence([moveUp,moveDown])
                print(car.presentation.position.y)
                car.runAction(moveSequence, completionHandler: nil)
            }
            print("up")
//        case UISwipeGestureRecognizer.Direction.down :
//            print("down")
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
        if !paused{
            gameTime += interval1
//            let roadToSpawn = roads.allCases.randomElement()!
//            let o4=obs(pos: SCNVector3(roadToSpawn.rawValue,7,-100), vel: SCNVector3(0,0,-150))
//            scene.rootNode.addChildNode(o4)
            updateHUD()}
        
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }

        switch key.keyCode {
        case .keyboardUpArrow:
            moveCar(direction: .up)
        case .keyboardLeftArrow:
            moveCar(direction: .left)
        case .keyboardRightArrow:
            moveCar(direction: .right)
        default:
            super.pressesBegan(presses, with: event)
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if contact.nodeB.name == "obstacle" && contact.nodeA.name == "car" {
            print("game over",contact.nodeA.name!,contact.nodeB.name!)
            gameOver()
            //    contact.
        }
    }
    
    func initialObs(){
        let o1=obs(pos: SCNVector3(roads.roadLeft.rawValue,7,-300), vel: SCNVector3(0,0,-150))
        scene.rootNode.addChildNode(o1)
        let o2=obs(pos: SCNVector3(roads.roadMiddle.rawValue,7,-500), vel: SCNVector3(0,0,-150))
        scene.rootNode.addChildNode(o2)
        let o3=obs(pos: SCNVector3(roads.roadRight.rawValue,7,-600), vel: SCNVector3(0,0,-150))
        scene.rootNode.addChildNode(o3)
        
    }
    func obs(pos:SCNVector3,vel:SCNVector3)->SCNNode{
        
        var obstacle:SCNNode!
        let geometry = SCNBox(width: 10.0, height: 5.0, length: 5.0, chamferRadius: 0.2)
        obstacle = SCNNode( geometry : geometry)
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
        var mes="your Score:\(score)"
        scene.isPaused=true
        paused=true
        
//        for s in Const.CDscores{
//            if score > s.hscore {
////                Const.highScores.remove(at: 4)
////                Const.highScores.append(score)x
//                mes="your Score:\(score) \n New Highscore!"
//                
////                storeScore(score: self.score, date: Date())
//                
//                break
//            }
//            
//        }
//        storeScore(score: self.score, date: Date())
        //        gameOverAlert(score: score, VC: self,message: mes)
        let alertController = UIAlertController(title: "Game Over!", message: mes, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "Main Menu", style: .default) { (action) in self.dismiss(animated: true, completion: nil)}
        let highScoreAction = UIAlertAction(title: "High Scores", style: .default) { (action) in
            self.dismiss(animated: true, completion: {self.highScoreClosure()})
            
        }
        alertController.addAction(OKAction)
        alertController.addAction(highScoreAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true) {}
        }
        
    }
}


enum roads: Int, CaseIterable {
    case roadLeft = -15
    case roadMiddle = 0
    case roadRight = 15
}

enum moveCarDirection {
    case right
    case left
    case up
}
