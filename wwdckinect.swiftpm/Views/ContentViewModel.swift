//
//  ViewModel.swift
//  Meu App
//
//  Created by Lucas Flores on 06/02/24.
//

import Foundation
import UIKit

class ContentViewModel: ObservableObject {
    static var instance: ContentViewModel = ContentViewModel()
    @Published var confidenceLabel = ""
    @Published var actionLabel = ""
    @Published var imageView: UIImage?
    
    private init() {
        
    }
    
    static func getInstance() -> ContentViewModel {
        return instance
    }
}
