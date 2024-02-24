//
//  File.swift
//  
//
//  Created by Lucas Flores on 11/02/24.
//

import Foundation
import Vision
import SwiftUI

class ActionClassifier {
    public static let shared = ActionClassifier()
    @ObservedObject var gameViewModel: GameViewModel = GameViewModel.getInstance()
    typealias JointName = VNHumanBodyPoseObservation.JointName
    
    func predictActionFromPose(_ pose: Pose?) -> ActionPrediction {

        guard let pose = pose else { return ActionPrediction(.noPerson) }
        let leftWristJoint = pose.landmarks.first(where: { $0.name == JointName.leftWrist })
        let rightWristJoint = pose.landmarks.first(where: { $0.name == JointName.rightWrist })
        let neckJoint = pose.landmarks.first(where: { $0.name == JointName.neck })
        let leftHipJoint = pose.landmarks.first(where: { $0.name == JointName.leftHip })
        let rightHipJoint = pose.landmarks.first(where: { $0.name == JointName.rightHip })
        var isUsingHips: Bool = false
        var bodyX: Double
        var bodyY: Double

        if let neckJoint = neckJoint {
            bodyX = neckJoint.location.x
            bodyY = neckJoint.location.y
        }
        else if let leftHipJoint = leftHipJoint, let rightHipJoint = rightHipJoint {
            bodyX = (leftHipJoint.location.x + rightHipJoint.location.x)/2
            bodyY = (leftHipJoint.location.y + rightHipJoint.location.y)/2
            isUsingHips = true
        }
        else {
            return ActionPrediction(.noPerson)
        }
        
        if (!self.gameViewModel.isGameOngoing) {
            if ((leftWristJoint?.location.y ?? -1)  > bodyY) {
                return ActionPrediction(label: "raising_right_hand")
            }
            
            if ((rightWristJoint?.location.y ?? -1)  > bodyY) {
                return ActionPrediction(label: "raising_left_hand")
            }
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
        
        if (isUsingHips) {
            if (bodyY <= 0.6) {
                action = "standing"
            }
            else {
                action = "jumping"
            }
        }
        else if (!isUsingHips) {
            if (bodyY <= 0.8) {
                action = "standing"
            }
            else {
                action = "jumping"
            }
        }
        else {
            action = "standing"
        }
        
        
        return ActionPrediction(label: "\(action)_\(position)")
    }
}
