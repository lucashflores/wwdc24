//
//  MainView.swift
//  WWDCKinect
//
//  Created by Lucas Flores on 18/02/24.
//

import SwiftUI

struct MainView: View {
    @State var currentScreen: Screen = .menu
    
    var body: some View {
        if (currentScreen == .menu) {
            MenuView(currentScreen: $currentScreen)
        }
        else if (currentScreen == .game) {
            GameView(currentScreen: $currentScreen)
        }
        else if (currentScreen == .score) {
            //ScoreView
        }
        else if (currentScreen == .shop) {
            //ShopView
        }
        else if (currentScreen == .settings) {
            //SettingsView
        }
    }
}

enum Screen: Int {
    case menu = 1
    case game = 2
    case score = 3
    case shop = 4
    case settings = 5
}

#Preview {
    MainView()
}
