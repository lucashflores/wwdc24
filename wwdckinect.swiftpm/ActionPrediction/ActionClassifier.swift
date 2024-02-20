//
//  File.swift
//  
//
//  Created by Lucas Flores on 11/02/24.
//

import Foundation
import Vision

class ActionClassifier {
    public static let shared = ActionClassifier()
    typealias JointName = VNHumanBodyPoseObservation.JointName
    
    func predictActionFromPose(_ pose: Pose?) -> ActionPrediction {

        guard let pose = pose else { return ActionPrediction(.noPerson) }
        let neckJoint = pose.landmarks.first(where: { $0.name == JointName.neck })
        let leftHipJoint = pose.landmarks.first(where: { $0.name == JointName.leftHip })
        let rightHipJoint = pose.landmarks.first(where: { $0.name == JointName.rightHip })
        var bodyX: Double
        var bodyY: Double

        if let neckJoint = neckJoint {
            bodyX = neckJoint.location.x
            bodyY = neckJoint.location.y
        }
        else if let leftHipJoint = leftHipJoint, let rightHipJoint = rightHipJoint {
            bodyX = (leftHipJoint.location.x + rightHipJoint.location.x)/2
            bodyY = (leftHipJoint.location.y + rightHipJoint.location.y)/2
        }
        else {
            return ActionPrediction(.noPerson)
        }
        
        var position: String
        var action: String
        if (bodyX <= 0.40) {
            position = "left"
        }
        else if (bodyX > 0.40 && bodyX < 0.60) {
            position = "middle"
        }
        else {
            position = "right"
        }
        
        if (neckJoint != nil) {
//            if (bodyY <= 0.45) {
//                action = "crouching"
//            }
            if (bodyY <= 0.80) {
                action = "standing"
            }
            else {
                action = "jumping"
            }
        }
        else {
            action = "jumping"
        }
        return ActionPrediction(label: "\(action)_\(position)", confidence: 100)
    }
}
