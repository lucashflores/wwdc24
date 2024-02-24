/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The app's main view controller.
*/

import UIKit
import Vision
import AVFoundation
import SwiftUI
import SceneKit
import SpriteKit

@available(iOS 14.0, *)
class MainViewController: UIViewController {
    @ObservedObject var cameraViewModel: CameraViewModel = CameraViewModel.getInstance()
    
    var queue = DispatchQueue(label: "com.lucashflores.wwdckinect", attributes: .concurrent)

    var videoCapture: VideoCapture!

    var videoProcessingChain: VideoProcessingChain!

    var actionFrameCounts = [String: Int]()
}

// MARK: - View Controller Events
extension MainViewController {
    /// Configures the main view after it loads.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Disable the idle timer to prevent the screen from locking.
        UIApplication.shared.isIdleTimerDisabled = true

        // Set the view controller as the video-processing chain's delegate.
        videoProcessingChain = VideoProcessingChain()
        videoProcessingChain.delegate = self

        // Begin receiving frames from the video capture.
        if let sublayers = self.view.layer.sublayers {
            for sublayer in sublayers {
                if sublayer.isKind(of: AVCaptureVideoPreviewLayer.self) {
                    sublayer.removeFromSuperlayer()
                }
            }
        }
        startVideoCapture()
    }
    
    func startVideoCapture() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoCapture.updateDeviceOrientation()
    }
}


// MARK: - Video Capture Delegate
extension MainViewController: VideoCaptureDelegate {
    func videoCapture(_ videoCapture: VideoCapture,
                      didCreate framePublisher: FramePublisher) {
        videoProcessingChain.upstreamFramePublisher = framePublisher
    }
}

// MARK: - video-processing chain Delegate
extension MainViewController: VideoProcessingChainDelegate {
    func videoProcessingChain(_ chain: VideoProcessingChain,
                              didPredict actionPrediction: ActionPrediction,
                              for frameCount: Int) {
        updateUILabelsWithPrediction(actionPrediction)
    }

    func videoProcessingChain(_ chain: VideoProcessingChain,
                              didDetect poses: [Pose]?,
                              in frame: CGImage) {

        DispatchQueue.global(qos: .userInteractive).async {
            self.drawPoses(poses, onto: frame)
        }
    }
}

// MARK: - Helper methods
extension MainViewController {
    private func addFrameCount(_ frameCount: Int, to actionLabel: String) {
        let totalFrames = (actionFrameCounts[actionLabel] ?? 0) + frameCount

        actionFrameCounts[actionLabel] = totalFrames
        if (totalFrames < 15) {
            videoCapture.restartCaptureSession()
        }
    }

    private func updateUILabelsWithPrediction(_ prediction: ActionPrediction) {
        DispatchQueue.main.async {
            let label = prediction.label
            self.cameraViewModel.actionLabel = label
            NotificationCenter.default.post(name: Notification.Name("action_detected"), object: label, userInfo: nil)
        }
    }

    private func drawPoses(_ poses: [Pose]?, onto frame: CGImage) {
        let renderFormat = UIGraphicsImageRendererFormat()
        renderFormat.scale = 1.0

        let frameSize = CGSize(width: frame.width, height: frame.height)
        let poseRenderer = UIGraphicsImageRenderer(size: frameSize,
                                                   format: renderFormat)

        let frameWithPosesRendering = poseRenderer.image { rendererContext in
            let cgContext = rendererContext.cgContext

            let inverse = cgContext.ctm.inverted()

            cgContext.concatenate(inverse)
            
            let imageRectangle = CGRect(origin: .zero, size: frameSize)
            cgContext.draw(frame, in: imageRectangle)

            let pointTransform = CGAffineTransform(scaleX: frameSize.width,
                                                   y: frameSize.height)

            guard let poses = poses else { return }

            // Draw all the poses Vision found in the frame.
            for pose in poses {
                // Draw each pose as a wireframe at the scale of the image.
                pose.drawWireframeToContext(cgContext, applying: pointTransform)
            }
        }
        
        DispatchQueue.main.async { self.cameraViewModel.imageView = frameWithPosesRendering }
    }
}

extension MainViewController {
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }
        
        switch key.keyCode {
        case .keyboardUpArrow:
            NotificationCenter.default.post(name: Notification.Name("didPressUpArrowKey"), object: nil, userInfo: nil)
        case .keyboardLeftArrow:
            NotificationCenter.default.post(name: Notification.Name("didPressLeftArrowKey"), object: nil, userInfo: nil)
        case .keyboardRightArrow:
            NotificationCenter.default.post(name: Notification.Name("didPressRightArrowKey"), object: nil, userInfo: nil)
        default:
            super.pressesBegan(presses, with: event)
        }
    }
}

struct MainViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = MainViewController
    
    private let controller: MainViewController
    
    init() {
        controller = MainViewController()
    }
    
    func updateUIViewController(_ uiViewController: MainViewController, context: Context) {
        
    }
    
    
    func makeUIViewController(context: Context) -> MainViewController {
            controller
    }
}
