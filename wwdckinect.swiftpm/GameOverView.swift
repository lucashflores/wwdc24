//
//  GameOverView.swift
//  WWDCKinect
//
//  Created by Lucas Flores on 18/02/24.
//

import SwiftUI

struct GameOverView: View {
    @Binding var currentScreen: Screen
    var score: Int
    
    var body: some View {
        VStack(spacing: 80) {
            VStack(spacing: 20) {
                Text("Game Over!")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundStyle(.white)
                Text("Your score is: \(score)")
                    .font(.system(size: 60))
                    .foregroundStyle(.white)
            }
            
            HStack(spacing: 80) {
                CardButtonView(iconName: "arrow.left", buttonText: "Main Menu")
                    .onTapGesture {
                        NotificationCenter.default.post(name: Notification.Name("restartGame"), object: nil, userInfo: nil)
                        currentScreen = .menu
                    }
                CardButtonView(iconName: "arrow.circlepath", buttonText: "Play Again")
                    .onTapGesture {
                        NotificationCenter.default.post(name: Notification.Name("restartGame"), object: nil, userInfo: nil)
                    }
            }
            
            Text("Stand left if you want to go back to main menu or stand right if you want to play again")
                .font(.system(size: 40))
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    GameOverView(currentScreen: .constant(.game), score: 100)
}
