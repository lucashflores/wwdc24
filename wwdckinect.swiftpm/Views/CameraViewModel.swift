//
//  ViewModel.swift
//  Meu App
//
//  Created by Lucas Flores on 06/02/24.
//

import Foundation
import UIKit

class CameraViewModel: ObservableObject {
    static var instance: CameraViewModel = CameraViewModel()
    @Published var actionLabel = ""
    @Published var imageView: UIImage?

 
    
    private init() {
        
    }
    
    static func getInstance() -> CameraViewModel {
        return instance
    }
}
