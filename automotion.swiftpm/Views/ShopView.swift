//
//  SwiftUIView.swift
//  
//
//  Created by Lucas Flores on 24/02/24.
//

import SwiftUI

struct ShopView: View {
    @Binding var currentScreen: Screen
    @State var coins: Int = 0
    
    var body: some View {
        VStack {
            Text("\(coins)")
                .foregroundStyle(.white)
                .font(.system(size: 60, weight: .bold))
        }
        .onAppear {
            coins = UserDefaults.standard.integer(forKey: "coins")
            print(coins)
        }
    }
}

#Preview {
    ShopView(currentScreen: .constant(.shop))
}
