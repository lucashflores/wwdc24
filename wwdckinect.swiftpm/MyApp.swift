import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
//                .onAppear {
//                    DispatchQueue.main.asyncAfter(0.1) {
//                        if let window = NSApplication.shared.windows.last {
//                            window.toggleFullScreen(nil)
//                        }
//                    }
//                }
        }
    }
}
