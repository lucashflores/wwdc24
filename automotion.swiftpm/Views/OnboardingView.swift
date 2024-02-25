//
//  SwiftUIView.swift
//  
//
//  Created by Lucas Flores on 23/02/24.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var currentScreen: Screen
    @State var hadPreviousSizeConfigSaved: Bool = true
    @State var screenSizeReduced = false
    @State var changesCount: Int = 0
    @State private var showingAlert = false
    
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
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
                            if (screenSizeReduced && (!hadPreviousSizeConfigSaved && changesCount < 2)) {
                                showingAlert = true
                            }
                            else {
                                currentScreen = .menu
                            }
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
                        .alert(isPresented:$showingAlert) {
                            Alert(
                                title: Text("It seems the size of the screen never changed. if you already have full screen toggled, just press Yes, otherwise make sure to toggle it before entering the game."),
                                message: Text("The game experience will be hindered in case full screen is not toggled on this screen!"),
                                primaryButton: .default(Text("Yes")) {
                                    currentScreen = .menu
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                }
                .onAppear {
                    UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { windowScene in
                        windowScene.sizeRestrictions?.minimumSize = CGSize(width: 1250, height: 1250)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                if (UserDefaults.standard.value(forKey: "fullScreenWidth") == nil && UserDefaults.standard.value(forKey: "fullScreenHeight") == nil) {
                    hadPreviousSizeConfigSaved = false
                }
            }
            .onChange(of: proxy.size) { newSize in
                changesCount += 1
                let fullScreenWidth: Double? = UserDefaults.standard.value(forKey: "fullScreenWidth") as? Double
                if (fullScreenWidth == nil) {
                    UserDefaults.standard.setValue(newSize.width, forKey: "fullScreenWidth")
                }
                else if (newSize.width > CGFloat(fullScreenWidth ?? 0)) {
                    UserDefaults.standard.setValue(newSize.width, forKey: "fullScreenWidth")
                }

                
                let fullScreenHeight: Double? = UserDefaults.standard.value(forKey: "fullScreenHeight") as? Double
                if (fullScreenHeight == nil) {
                    UserDefaults.standard.setValue(newSize.height, forKey: "fullScreenHeight")
                }
                else if (newSize.height > CGFloat(fullScreenHeight ?? 0)) {
                    UserDefaults.standard.setValue(newSize.height, forKey: "fullScreenHeight")
                }
                
                if (newSize.height < CGFloat(fullScreenHeight ?? 0) && newSize.width < CGFloat(fullScreenWidth ?? 0)) {
                    screenSizeReduced = true
                }
            }
        }
    }
}


#Preview {
    OnboardingView(currentScreen: .constant(.onboarding))
}
