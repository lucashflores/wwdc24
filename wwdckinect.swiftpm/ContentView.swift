import SwiftUI
import AVFoundation

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel.getInstance()
    
    var body: some View {
        ZStack {
            MainViewControllerRepresentable()
            if let camera = self.viewModel.imageView {
                Image(uiImage: camera)
            }
            else {
                Image(systemName: "camera")
            }
            
        }
//        VStack {
//            Text("Hello World")
//        }
//        
    }
}


