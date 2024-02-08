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
            
            VStack {
                VStack {
                    Text(self.viewModel.actionLabel)
                        .font(.system(size: 60))
                    Text(self.viewModel.confidenceLabel)
                        .font(.system(size: 36))
                }
                .padding()
                .background {
                    Color.black.opacity(0.5)
                }
            }
            .padding(.top, 800)
            
            
        }
//        VStack {
//            Text("Hello World")
//        }
//        
    }
}


