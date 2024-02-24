//
//  GameOverView.swift
//  WWDCKinect
//
//  Created by Lucas Flores on 18/02/24.
//

import SwiftUI

struct GameOverView: View {
    @Binding var currentScreen: Screen
    @Binding var score: Int
    @Binding var coins: Int
    
    var body: some View {
        VStack(spacing: 80) {
            VStack(spacing: 20) {
                Text("Game Over!")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundStyle(.white)
                Text("Your score is: \(score)")
                    .font(.system(size: 50))
                    .foregroundStyle(.white)
                Text("Your collected \(coins) coins")
                    .font(.system(size: 50))
                    .foregroundStyle(.white)
            }
            
            HStack(spacing: 80) {
                CardButtonView(iconName: "arrow.left", buttonText: "Main Menu")
                    .onTapGesture {
                        mainMenu()
                    }
                CardButtonView(iconName: "arrow.circlepath", buttonText: "Play Again")
                    .onTapGesture {
                        notifyGameRestart()
                    }
            }
            
            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 0) {
                Text("Raise your left hand to the height of your neck if you")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
                Text("want to go back to menu or your right one to play again")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
            }
            .padding()
            .background {
                Color.black.opacity(0.5)
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: Notification.Name("didRaiseLeftHand"), object: nil, queue: nil) { (notification) in
                mainMenu()
            }
            
            NotificationCenter.default.addObserver(forName: Notification.Name("didRaiseRightHand"), object: nil, queue: nil) { (notification) in
                notifyGameRestart()
            }
        }
    }
    
    
    func notifyGameRestart() {
        NotificationCenter.default.post(name: Notification.Name("restartGame"), object: nil, userInfo: nil)
    }
    
    func mainMenu() {
        notifyGameRestart()
        currentScreen = .menu
    }
}

#Preview {
    GameOverView(currentScreen: .constant(.game), score: .constant(100), coins: .constant(50))
}
