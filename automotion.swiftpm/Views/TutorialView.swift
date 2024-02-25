//
//  SwiftUIView.swift
//  
//
//  Created by Lucas Flores on 23/02/24.
//

import SwiftUI
import SceneKit

struct TutorialView: View {
    @Binding var currentScreen: Screen
    
    @ObservedObject var cameraViewModel = CameraViewModel.getInstance()
    @State var currentStep: Step = .intro
    @State var isActionLocked = false
    
    var body: some View {
        ZStack {
            MainViewControllerRepresentable()
            Group {
                
                if (currentStep.rawValue >= Step.intro4.rawValue) {
                    HStack {
                        if (currentStep == .standMiddleSuccess || currentStep == .standLeftSuccess || currentStep == .standRightSuccess || currentStep == .jumpSuccess) {
                            Text(getText(step: Step(rawValue: currentStep.rawValue - 1)!))
                                .font(.system(size: 40, weight: .bold))
                                .opacity(0.5)
                                .padding(.horizontal, 100)
                        }
                        else {
                            Text(getText(step: currentStep))
                                .font(.system(size: 40, weight: .bold))
                                .padding(.horizontal, 100)
                        }
                        VStack(spacing: 0) {
                            if let camera = self.cameraViewModel.imageView {
                                Image(uiImage: camera)
                                    .resizable()
                                    .frame(width: 800, height: 1200)
                            }
                            else {
                                Image(systemName: "camera")
                                
                            }
                            
                            VStack {
                                VStack {
                                    Text(self.cameraViewModel.actionLabel)
                                        .font(.system(size: 60))
                                }
                                .frame(maxWidth: 750)
                                .background {
                                    Color.black.opacity(0.5)
                                }
                            }
                        }
                        if (currentStep == .standMiddleSuccess || currentStep == .standLeftSuccess || currentStep == .standRightSuccess || currentStep == .jumpSuccess) {
                            Text(getText(step: currentStep))
                                .foregroundStyle(.green)
                                .font(.system(size: 50, weight: .bold))
                                .padding(.horizontal, 100)
                        }
                        
                    }
                }
                else {
                    VStack(spacing: 50) {
                        VStack(spacing: 0) {
                            if let camera = self.cameraViewModel.imageView {
                                Image(uiImage: camera)
                                    .resizable()
                                    .frame(width: 600, height: 900)
                            }
                            else {
                                Image(systemName: "camera")
                                
                            }
                            
                            VStack {
                                VStack {
                                    Text(self.cameraViewModel.actionLabel)
                                        .font(.system(size: 60))
                                }
                                .frame(maxWidth: 600)
                                .background {
                                    Color.black.opacity(0.5)
                                }
                            }
                        }
                        
                        Text(getText(step: currentStep))
                            .font(.system(size: 40, weight: .bold))
                            .padding(.vertical)
                            .padding(.horizontal, 50)
                        
                        
                        Button {
                            currentStep = Step(rawValue: currentStep.rawValue + 1)!
                        } label: {
                            HStack {
                                Text("Next")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 30, weight: .bold))
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 30, weight: .bold))
                            }
                            .padding()
                            .border(.white, width: 5)
                        }
                        
                    }
                }
            }
            .transition(.slide)
        }
        
        .onChange(of: currentStep) { newStep in
            isActionLocked = true
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                isActionLocked = false
            }
        }
        .onAppear {
            
            NotificationCenter.default.addObserver(forName: Notification.Name("action_detected"), object: nil, queue: nil) { (notification) in
                let action = notification.object as! String
                if (isActionLocked) {
                    return
                }
                if (action == "standing_middle") {
                    if (currentStep == .standMiddle) {
                        currentStep = .standMiddleSuccess
                    }
                }
                else if (action == "standing_left") {
                    if (currentStep == .standLeft) {
                        currentStep = .standLeftSuccess
                    }
                }
                else if (action == "standing_right") {
                    if (currentStep == .standRight) {
                        currentStep = .standRightSuccess
                    }
                }
                else if (action.contains("jumping")) {
                    if (currentStep == .jump) {
                        currentStep = .jumpSuccess
                    }
                }
                else if (action == "raising_right_hand") {
                    if (currentStep == .end) {
                        NotificationCenter.default.post(name: Notification.Name("dismissMain"), object: nil)
                        currentScreen = .game
                    }
                    else if (currentStep.rawValue >= 3 && currentStep != .standMiddle && currentStep != .standLeft && currentStep != .standRight && currentStep != .standLeft && currentStep != .jump) {
                        currentStep = Step(rawValue: currentStep.rawValue + 1)!
                    }
                }
                
                else if (action == "raising_left_hand") {
                    if (currentStep == .end) {
                        NotificationCenter.default.post(name: Notification.Name("dismissMain"), object: nil)
                        currentScreen = .menu
                    }
                }

            }
        }
    }
}

func getText(step: Step) -> String {
    switch step {
        case .intro:
            return "Now we are going to set you up so you can play the game!"
        case .intro2:
            return "First make sure that there is only you appearing at the camera."
        case .intro3:
            return "Next, position your MacBook screen to create 90-degree angle with its base."
        case .intro4:
            return "Now you will need to stand up and move away from the camera, until your hips are visible. Make sure to remove any objects in the camera line of sight. When you are ready, raise your right hand to the height of your neck to go the next step."
        case .standLeft:
            return "Raising your right hand will be the default movement for going into the next step from now on. Move to the left side of the screen so that the action detected is standing_left."
        case .standLeftSuccess:
            return "Good job, raise your right hand when you are ready to go the next one."
        case .standMiddle:
            return "Now, move away from the screen until your hip joints are visible and the action detected is standing_middle"
        case .standMiddleSuccess:
            return "Good, raise your right hand to proceed."
        case .standRight:
            return "Now stand at the right side of the screen, so the action detected is standing_right."
        case .standRightSuccess:
            return "Well done!"
        case .dodgingExplanation:
            return "Now you've learned the basics of dodging. In AutoMotion, obstacles will appear in one of the three roads. One of the obstacles, the stones, can only be dodged and the other, the traps, can be dodged or jumped, which we will cover next, but this makes dodging the best way to avoid obstacles."
        case .jump:
            return "Now you need to jump in any section of the screen. If you are having a hard time doing this, try to get closer to the camera."
        case .jumpSuccess:
            return "Well done, this was the last move we were going to learn in this tutorial. Raise your right hand to go to the next step."
        case .jumpingExplanation:
            return "Jumping is the other way to avoid obstacles, but it only works for traps, so watch out for that. Also, one thing that you need to know is about the coins. Coins also spawn on the roads but can be collected and traded for new cars on the shop."
        case .end:
            return "You are all set to play now. Raise your left hand to go back to menu or the right one to go straight into the game. Have fun!"
    }
}

enum Step: Int {
    case intro = 0
    case intro2
    case intro3
    case intro4
    case standLeft
    case standLeftSuccess
    case standMiddle
    case standMiddleSuccess
    case standRight
    case standRightSuccess
    case dodgingExplanation
    case jump
    case jumpSuccess
    case jumpingExplanation
    case end
}

#Preview {
    TutorialView(currentScreen: .constant(.tutorial))
}
