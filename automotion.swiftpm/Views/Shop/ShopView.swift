//
//  SwiftUIView.swift
//  
//
//  Created by Lucas Flores on 24/02/24.
//

import SwiftUI
import SceneKit

struct ShopView: View {
    @Binding var currentScreen: Screen
    @State var coins: Int = getCoins()
    @State var boughtCars: [Car] = getBoughtCars()
    @State var selectedCar: Car = getSelectedCar()
    
    var raceCarModel = ShopCarModel(car: .race, color: .red, scene: SCNScene(named: "race.scn")!, price: getPrice(car: .race))
    var futureCarModel = ShopCarModel(car: .future, color: .blue, scene: SCNScene(named: "raceFuture.scn")!, price: getPrice(car: .future))
    var taxiCarModel = ShopCarModel(car: .taxi, color: .yellow, scene: SCNScene(named: "taxi.scn")!, price: getPrice(car: .taxi))
    var truckCarModel = ShopCarModel(car: .truck, color: .green, scene: SCNScene(named: "truck.scn")!, price: getPrice(car: .truck))
    
    var body: some View {
        VStack {
            Text("\(coins)")
                .foregroundStyle(.white)
                .font(.system(size: 60, weight: .bold))
            VStack(spacing: 50) {
                HStack(spacing: 50) {
                    CarView(shopCarModel: self.raceCarModel, coins: $coins, boughtCars: $boughtCars, selectedCar: $selectedCar)
                    
                    CarView(shopCarModel: self.futureCarModel, coins: $coins, boughtCars: $boughtCars, selectedCar: $selectedCar)
                }
                
                HStack(spacing: 50) {
                    CarView(shopCarModel: self.taxiCarModel, coins: $coins, boughtCars: $boughtCars, selectedCar: $selectedCar)
                    
                    CarView(shopCarModel: self.truckCarModel, coins: $coins, boughtCars: $boughtCars, selectedCar: $selectedCar)
                }
            }
            
        }
    }
    
    func updateValues() {
        self.boughtCars = getBoughtCars()
        self.selectedCar = getSelectedCar()
        self.coins = getCoins()
    }

}

func getPrice(car: Car) -> Int {
    switch car {
        case .race:
            return 0
        case .taxi:
            return 5
        case .truck:
            return 10
        case .future:
            return 20
    }
}

func getCoins() -> Int {
    let coins =  UserDefaults.standard.object(forKey: "coins") as? Int
    if (coins == nil) {
        return 0
    }
    return coins!
}

func getSelectedCar() -> Car {
    let selectedCar = UserDefaults.standard.value(forKey: "selectedCar") as? String
    if (selectedCar == Car.truck.rawValue) {
        return .truck
    }
    else if (selectedCar == Car.taxi.rawValue) {
        return .taxi
    }
    else if (selectedCar == Car.future.rawValue) {
        return .future
    }
    return .race
}

func selectCar(car: Car) {
    let boughtCars = getBoughtCars()
    if (boughtCars.contains(car)) {
        UserDefaults.standard.setValue(car.rawValue, forKey: "selectedCar")
    }
}

func getBoughtCars() -> [Car] {
    let boughtCars = UserDefaults.standard.value(forKey: "boughtCars") as? [String]
    if (boughtCars == nil) {
        return [.race]
    }
    return boughtCars!.map({ car in
        return Car(rawValue: car)!
    })
}

func buyCar(car: Car) -> Bool {
    let coins = getCoins()
    var boughtCars = getBoughtCars()
    if (coins >= getPrice(car: car)) {
        boughtCars.append(car)
        UserDefaults.standard.setValue(boughtCars.map({ car in
            return car.rawValue
        }), forKey: "boughtCars")
        UserDefaults.standard.setValue(coins - getPrice(car: car), forKey: "coins")
        return true
    }
    return false
}



struct CarView: View {
    var shopCarModel: ShopCarModel
    @Binding var coins: Int
    @Binding var boughtCars: [Car]
    @Binding var selectedCar: Car
    
    @State var isShowingAlert = false
    @State var alertText = ""
    
    
    var body: some View {
        VStack(spacing: 0) {
            Text(shopCarModel.car.rawValue)
                .foregroundStyle(shopCarModel.color)
                .font(.system(size: 40, weight: .bold))
                .frame(width: 400, height: 50)
                .background { Color("shopCarTextBg", bundle: .module)
            }
            SceneView (scene: shopCarModel.scene, options: [
                SceneView.Options.allowsCameraControl, SceneView.Options.autoenablesDefaultLighting])
            .frame(width: 400, height: 400)
            
            Button {
                if (!self.boughtCars.contains(shopCarModel.car)) {
                    if (buyCar(car: shopCarModel.car)) {
                        alertText = "Car bought!"
                        isShowingAlert = true
                        updateValues()
                    }
                    else {
                        alertText = "Not enough money!"
                        isShowingAlert = true
                    }
                }
                else if (!(self.selectedCar == shopCarModel.car)) {
                    selectCar(car: shopCarModel.car)
                    updateValues()
                }
            } label: {
                Text(self.boughtCars.contains(shopCarModel.car) ? (self.selectedCar == shopCarModel.car ? "Selected" : "Select") : "Buy - \(shopCarModel.price) coins")
                    .foregroundStyle(.white)
                    .font(.system(size: 40, weight: .bold))
                    .frame(width: 400, height: 50)
                    .background { Color("shopCarTextBg", bundle: .module)
                }
            }
            .alert(isPresented: $isShowingAlert) {
                Alert(
                    title: Text(alertText),
                    message: nil,
                    dismissButton: .default(Text("Ok")) {
                        isShowingAlert = false
                        alertText = ""
                    }
                )
            }
            

        }

    }
    func updateValues() {
        self.boughtCars = getBoughtCars()
        self.selectedCar = getSelectedCar()
        self.coins = getCoins()
    }
}

#Preview {
    ShopView(currentScreen: .constant(.shop))
}
