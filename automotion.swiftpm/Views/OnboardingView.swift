//
//  SwiftUIView.swift
//  
//
//  Created by Lucas Flores on 23/02/24.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var currentScreen: Screen
    
    var body: some View {
        VStack {
            VStack(spacing: 120) {
                VStack(spacing: 32) {
                    Image(systemName: "figure")
                        .font(.system(size: 80))
                    VStack(spacing: 5) {
                        Text("Automotion is a game that uses pose detection")
                            .font(.system(size: 35, weight: .bold))
                        Text("technology to enhance the endless runner game experience")
                            .font(.system(size: 35, weight: .bold))
                    }
                }
                
                VStack(spacing: 32) {
                    HStack(spacing: 32) {
                        Image(systemName: "rectangle.inset.filled")
                            .font(.system(size: 80))
                        Image(systemName: "camera.fill")
                            .font(.system(size: 80))
                    }
                    VStack(spacing: 5) {
                        Text("The game needs to be played on full screen")
                            .font(.system(size: 35, weight: .bold))
                        Text("and will ask for camera permission later")
                            .font(.system(size: 35, weight: .bold))
                    }
                }
                
                VStack(spacing: 32) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 80))
                    VStack(spacing: 5) {
                        Text("Please be aware of your surroundings when playing")
                            .font(.system(size: 35, weight: .bold))
                        Text("and make sure to have an unobstructed space to play")
                            .font(.system(size: 35, weight: .bold))
                    }
                }
                
                Button {
                    currentScreen = .menu
                } label: {
                    HStack {
                        Text("Next")
                            .foregroundStyle(.white)
                            .font(.system(size: 30, weight: .bold))
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.white)
                            .font(.system(size: 30, weight: .bold))
                    }
                }
                .padding()
                .border(.white, width: 5)
            }

            
                
        }
        .onAppear {
            UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { windowScene in
                windowScene.sizeRestrictions?.minimumSize = CGSize(width: 1250, height: 1250)
            }
        }
    }
}

#Preview {
    OnboardingView(currentScreen: .constant(.onboarding))
}
