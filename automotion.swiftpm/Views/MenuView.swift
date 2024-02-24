//
//  MenuVIEW.swift
//  WWDCKinect
//
//  Created by Lucas Flores on 17/02/24.
//

import SwiftUI

struct MenuView: View {
    @Binding var currentScreen: Screen
    
    var body: some View {
        ZStack {
            Image("buttonbg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            VStack {
                Text("Main Menu")
                    .font(.system(size: 100, weight: .bold))
                    .padding(.bottom, 250)
                    .foregroundStyle(.white)
                    
                                
                HStack(spacing: 200) {
                    CardButtonView(iconName: "gamecontroller.fill", buttonText: "Play")
                        .onTapGesture {
                            currentScreen = .game
                        }
                    CardButtonView(iconName: "graduationcap.fill", buttonText: "Tutorial")
                        .onTapGesture {
                            currentScreen = .tutorial
                        }
                    CardButtonView(iconName: "storefront.fill", buttonText: "Shop")
                    CardButtonView(iconName: "door.left.hand.open", buttonText: "Exit")
                        .onTapGesture {
                            exit(0)
                        }
                }
                .padding(.bottom, 250)
            }
        }
        .onAppear {
            
        }
    }
}

#Preview {
    MenuView(currentScreen: .constant(.menu))
}
