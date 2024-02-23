//
//  File 2.swift
//  
//
//  Created by Lucas Flores on 18/02/24.
//

import Foundation
//
//  ViewModel.swift
//  Meu App
//
//  Created by Lucas Flores on 06/02/24.
//

import Foundation
import UIKit

class GameViewModel: ObservableObject {
    static var instance: GameViewModel = GameViewModel()
    @Published var gameOver = false
    @Published var score: Int = 0
    @Published var coins: Int = 0

 
    
    private init() {
        
    }
    
    static func getInstance() -> GameViewModel {
        return instance
    }
}


