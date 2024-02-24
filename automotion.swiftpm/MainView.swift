//
//  MainView.swift
//  WWDCKinect
//
//  Created by Lucas Flores on 18/02/24.
//

import SwiftUI

struct MainView: View {
    @State var currentScreen: Screen = .calibration
    
    var body: some View {
        if (currentScreen == .onboarding) {
            OnboardingView(currentScreen: $currentScreen)
        }
        else if (currentScreen == .menu) {
            MenuView(currentScreen: $currentScreen)
        }
        else if (currentScreen == .game) {
            GameView(currentScreen: $currentScreen)
        }
        else if (currentScreen == .calibration) {
            CalibrationView()
        }
        else if (currentScreen == .shop) {
            //ShopView
        }
    }
    
}

enum Screen: Int {
    case onboarding = 0
    case menu = 1
    case game = 2
    case shop = 3
    case calibration = 4
    
}

#Preview {
    MainView()
}
