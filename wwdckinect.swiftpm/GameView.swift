import SwiftUI
import AVFoundation

struct GameView: View {
    @Binding var currentScreen: Screen
    @ObservedObject var cameraViewModel = CameraViewModel.getInstance()
    @ObservedObject var gameViewModel = GameViewModel.getInstance()
    
    var body: some View {
        ZStack {
            GameViewControllerRepresentable()
            
            ZStack(alignment: .bottomTrailing) {
                MainViewControllerRepresentable()
                if let camera = self.cameraViewModel.imageView {
                    Image(uiImage: camera)
                        .resizable()
                        .frame(width: 600, height: 900)
                }
                else {
                    Image(systemName: "camera")
                    
                }
                
                VStack {
                    VStack {
                        Text(self.cameraViewModel.actionLabel)
                            .font(.system(size: 60))
                        Text(self.cameraViewModel.confidenceLabel)
                            .font(.system(size: 36))
                    }
                    .frame(maxWidth: 600)
                    .background {
                        Color.black.opacity(0.5)
                    }
                }
            }
            
            if (gameViewModel.gameOver) {
                GameOverView(currentScreen: $currentScreen, score: gameViewModel.score)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color.red)
        .edgesIgnoringSafeArea(.all)
        
        
    }
}
    


