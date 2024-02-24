//
//  SwiftUIView.swift
//  
//
//  Created by Lucas Flores on 23/02/24.
//

import SwiftUI

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
                                .padding()
                        }
                        else {
                            Text(getText(step: currentStep))
                                .font(.system(size: 40, weight: .bold))
                                .padding()
                        }
                        VStack(spacing: 0) {
                            if let camera = self.cameraViewModel.imageView {
                                Image(uiImage: camera)
                                    .resizable()
                                    .frame(width: 750, height: 1150)
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
                                .padding()
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
                        currentScreen = .menu
                    }
                    else if (currentStep.rawValue >= 3 && currentStep != .standMiddle && currentStep != .standLeft && currentStep != .standRight && currentStep != .standLeft && currentStep != .jump) {
                        currentStep = Step(rawValue: currentStep.rawValue + 1)!
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
        case .standMiddle:
            return "Now, move away from the screen until your hip joints are visible and the action detected is standing_middle"
        case .standMiddleSuccess:
            return "Good job, raise your right hand when you are ready to go the next one."
        case .standLeft:
            return "Move to the left side of the screen so that the action detected is standing_left."
        case .standLeftSuccess:
            return "Nice, raise your right hand again to go the next movement."
        case .standRight:
            return "Now stand at the right side of the screen, so the action detected is standing_right."
        case .standRightSuccess:
            return "Good, raise your right hand to go the last movement."
        case .jump:
            return "Now you need to jump in any section of the screen. If you are having a hard time doing this, try to get closer to the camera."
        case .jumpSuccess:
            return "Well done, this was the last move we were going to learn in this tutorial. Raise your right hand to go to the end."
        case .end:
            return "You are all set to play now. Raising your left hand is a valid move that will come in use later. Raise your right hand to leave the tutorial. Have fun!"
    }
}

enum Step: Int {
    case intro = 0
    case intro2
    case intro3
    case intro4
    case standMiddle
    case standMiddleSuccess
    case standLeft
    case standLeftSuccess
    case standRight
    case standRightSuccess
    case jump
    case jumpSuccess
    case end
}

#Preview {
    TutorialView(currentScreen: .constant(.tutorial))
}
