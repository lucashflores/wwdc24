//
//  File.swift
//  
//
//  Created by Lucas Flores on 24/02/24.
//

import Foundation
import SwiftUI
import SceneKit

struct ShopCarModel {
    var car: Car
    var color: Color
    var scene: SCNScene
    var price: Int
}

enum Car: String {
    case race = "Race"
    case future = "Future"
    case taxi = "Taxi"
    case truck = "Truck"
}
