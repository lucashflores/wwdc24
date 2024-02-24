//
//  SwiftUIView.swift
//  
//
//  Created by Lucas Flores on 23/02/24.
//

import SwiftUI

struct CalibrationView: View {
    @ObservedObject var cameraViewModel = CameraViewModel.getInstance()
    @State var currentStep: Step = .intro
    @State var counter: Int = 0
    var timer = Timer()
    
    var body: some View {
        ZStack {
            MainViewControllerRepresentable()
     
            VStack(spacing: 32) {
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
                
                Text("Now we are going to set you up so you can play the game!")
                    .font(.system(size: 60, weight: .bold))
            }
        }
        .onAppear {
        }
    }
}

enum Step: Int {
    case intro
    case standMiddle
    case standLeft
    case standRight
    case jump
    case raiseLeftHand
    case raiseRightHand
}

#Preview {
    CalibrationView()
}
