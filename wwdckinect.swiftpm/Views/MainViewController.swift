/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The app's main view controller.
*/

import UIKit
import Vision
import AVFoundation
import SwiftUI

@available(iOS 14.0, *)
class MainViewController: UIViewController {
    @ObservedObject var viewModel: ContentViewModel = ContentViewModel.getInstance()

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
        videoCapture = VideoCapture()
        videoCapture.delegate = self

//        updateUILabelsWithPrediction(.startingPrediction)
    }

    /// Configures the video captures session with the device's orientation.
    ///
    /// This is the app's first opportunity to retrieve the device's
    /// physical orientation with its hardware sensors.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Update the device's orientation.
        videoCapture.updateDeviceOrientation()
    }

    /// Notifies the video capture when the device rotates to a new orientation.
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        // Update the the camera's orientation to match the device's.
//        videoCapture.updateDeviceOrientation()
    }
}


// MARK: - Video Capture Delegate
extension MainViewController: VideoCaptureDelegate {
    /// Receives a video frame publisher from a video capture.
    /// - Parameters:
    ///   - videoCapture: A `VideoCapture` instance.
    ///   - framePublisher: A new frame publisher from the video capture.
    func videoCapture(_ videoCapture: VideoCapture,
                      didCreate framePublisher: FramePublisher) {
//        updateUILabelsWithPrediction(.startingPrediction)
        
        // Build a new video-processing chain by assigning the new frame publisher.
        videoProcessingChain.upstreamFramePublisher = framePublisher
    }
}

// MARK: - video-processing chain Delegate
extension MainViewController: VideoProcessingChainDelegate {
    /// Receives an action prediction from a video-processing chain.
    /// - Parameters:
    ///   - chain: A video-processing chain.
    ///   - actionPrediction: An `ActionPrediction`.
    ///   - duration: The span of time the prediction represents.
    /// - Tag: detectedAction
    func videoProcessingChain(_ chain: VideoProcessingChain,
                              didPredict actionPrediction: ActionPrediction,
                              for frameCount: Int) {

        if actionPrediction.isModelLabel {
            // Update the total number of frames for this action.
            addFrameCount(frameCount, to: actionPrediction.label)
        }

        // Present the prediction in the UI.
        updateUILabelsWithPrediction(actionPrediction)
    }

    /// Receives a frame and any poses in that frame.
    /// - Parameters:
    ///   - chain: A video-processing chain.
    ///   - poses: A `Pose` array.
    ///   - frame: A video frame as a `CGImage`.
    func videoProcessingChain(_ chain: VideoProcessingChain,
                              didDetect poses: [Pose]?,
                              in frame: CGImage) {
        // Render the poses on a different queue than pose publisher.
        DispatchQueue.global(qos: .userInteractive).async {
            // Draw the poses onto the frame.
            self.drawPoses(poses, onto: frame)
        }
    }
}

// MARK: - Helper methods
extension MainViewController {
    /// Add the incremental duration to an action's total time.
    /// - Parameters:
    ///   - actionLabel: The name of the action.
    ///   - duration: The incremental duration of the action.
    private func addFrameCount(_ frameCount: Int, to actionLabel: String) {
        // Add the new duration to the current total, if it exists.
        let totalFrames = (actionFrameCounts[actionLabel] ?? 0) + frameCount

        // Assign the new total frame count for this action.
        actionFrameCounts[actionLabel] = totalFrames
    }

    /// Updates the user interface's labels with the prediction and its
    /// confidence.
    /// - Parameters:
    ///   - label: The prediction label.
    ///   - confidence: The prediction's confidence value.
    private func updateUILabelsWithPrediction(_ prediction: ActionPrediction) {
        // Update the UI's prediction label on the main thread.
        DispatchQueue.main.async {
            var label = prediction.label
            self.viewModel.actionLabel = label
            switch label {
                case "standing_middle":
                    NotificationCenter.default.post(name: Notification.Name("didStandInTheMiddle"), object: nil, userInfo: nil)
                case "standing_left":
                    NotificationCenter.default.post(name: Notification.Name("didStandInTheLeft"), object: nil, userInfo: nil)
                case "standing_right":
                    NotificationCenter.default.post(name: Notification.Name("didStandInTheRight"), object: nil, userInfo: nil)
                case "jumping_middle":
                    NotificationCenter.default.post(name: Notification.Name("didJumpInTheMiddle"), object: nil, userInfo: nil)
                case "jumping_left":
                    NotificationCenter.default.post(name: Notification.Name("didJumpInTheLeft"), object: nil, userInfo: nil)
                case "jumping_right":
                    NotificationCenter.default.post(name: Notification.Name("didJumpInTheRight"), object: nil, userInfo: nil)
                case "crouching_middle":
                    NotificationCenter.default.post(name: Notification.Name("didCrouchInTheMiddle"), object: nil, userInfo: nil)
                case "crouching_left":
                    NotificationCenter.default.post(name: Notification.Name("didCrouchInTheLeft"), object: nil, userInfo: nil)
                case "crouching_right":
                    NotificationCenter.default.post(name: Notification.Name("didCrouchInTheRight"), object: nil, userInfo: nil)
                default:
                    ()
            }
        }

        // Update the UI's confidence label on the main thread.
        let confidenceString = prediction.confidenceString ?? "Observing..."
        DispatchQueue.main.async { self.viewModel.confidenceLabel = confidenceString }
    }

    /// Draws poses as wireframes on top of a frame, and updates the user
    /// interface with the final image.
    /// - Parameters:
    ///   - poses: An array of human body poses.
    ///   - frame: An image.
    /// - Tag: drawPoses
    private func drawPoses(_ poses: [Pose]?, onto frame: CGImage) {
        // Create a default render format at a scale of 1:1.
        let renderFormat = UIGraphicsImageRendererFormat()
        renderFormat.scale = 1.0

        // Create a renderer with the same size as the frame.
        let frameSize = CGSize(width: frame.width, height: frame.height)
        let poseRenderer = UIGraphicsImageRenderer(size: frameSize,
                                                   format: renderFormat)

        // Draw the frame first and then draw pose wireframes on top of it.
        let frameWithPosesRendering = poseRenderer.image { rendererContext in
            // The`UIGraphicsImageRenderer` instance flips the Y-Axis presuming
            // we're drawing with UIKit's coordinate system and orientation.
            let cgContext = rendererContext.cgContext

            // Get the inverse of the current transform matrix (CTM).
            let inverse = cgContext.ctm.inverted()

            // Restore the Y-Axis by multiplying the CTM by its inverse to reset
            // the context's transform matrix to the identity.
            cgContext.concatenate(inverse)

            // Draw the camera image first as the background.
            let imageRectangle = CGRect(origin: .zero, size: frameSize)
            cgContext.draw(frame, in: imageRectangle)

            // Create a transform that converts the poses' normalized point
            // coordinates `[0.0, 1.0]` to properly fit the frame's size.
            let pointTransform = CGAffineTransform(scaleX: frameSize.width,
                                                   y: frameSize.height)

            guard let poses = poses else { return }

            // Draw all the poses Vision found in the frame.
            for pose in poses {
                // Draw each pose as a wireframe at the scale of the image.
                pose.drawWireframeToContext(cgContext, applying: pointTransform)
            }
        }

        // Update the UI's full-screen image view on the main thread.
        DispatchQueue.main.async { self.viewModel.imageView = frameWithPosesRendering }
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
