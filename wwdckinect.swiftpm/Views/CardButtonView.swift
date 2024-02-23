//
//  CardButtonView.swift
//  WWDCKinect
//
//  Created by Lucas Flores on 17/02/24.
//

import SwiftUI

struct CardButtonView: View {
    var iconName: String
    var buttonText: String
    
    var body: some View {
        ZStack {
            Color("cardbg")
                .frame(width: 350, height: 350)
                .border(.tertiary, width: 5)
            
            VStack(alignment: .center,  spacing: 50) {
                Image(systemName: iconName)
                
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 175, height: 175)
                    .foregroundColor(.white)
                
                
                Text(buttonText)
                    .foregroundStyle(.white)
                    .font(.system(size: 45, weight: .bold))
                
            }
            .padding()
        }
        
    }
}

#Preview {
    CardButtonView(iconName: "gear", buttonText: "Play")
}
