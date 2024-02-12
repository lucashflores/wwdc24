import SwiftUI
import AVFoundation

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel.getInstance()
    
    var body: some View {
        ZStack {
            GameViewControllerRepresentable()
            ZStack(alignment: .bottomTrailing) {
                MainViewControllerRepresentable()
                if let camera = self.viewModel.imageView {
                    Image(uiImage: camera)
                        .resizable()
                        .frame(width: 600, height: 900)
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
                    .frame(maxWidth: 600)
                    .background {
                        Color.black.opacity(0.5)
                    }
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color.red)
        .edgesIgnoringSafeArea(.all)
    }
}
    
struct GameViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = GameViewController
    private let gameViewController = GameViewController()
    
    func makeUIViewController(context: Context) -> GameViewController {
        gameViewController
    }
    
    func updateUIViewController(_ uiViewController: GameViewController, context: Context) {
        
    }
}


