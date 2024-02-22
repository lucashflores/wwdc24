/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Bundles an action label with a confidence value.
 The extension defines and generates placeholder predictions with labels that
 represent when the camera frame is devoid of people or when the model's
 confidence isn't high enough.
*/

/// Bundles an action label with a confidence value.
/// - Tag: ActionPrediction
struct ActionPrediction {
    /// The name of the action the Exercise Classifier predicted.
    let label: String

    init(label: String) {
        self.label = label
    }
}

extension ActionPrediction {
    /// Defines placeholder prediction labels beyond the scope of the
    /// action classifier model.

    /// A prediction that represents a time window that doesn't contain
    /// enough human body pose observations.
    static let startingPrediction = ActionPrediction(.starting)

    /// A prediction that represents a time window that doesn't contain
    /// enough human body pose observations.
    /// - Tag: noPersonPrediction
    static let noPersonPrediction = ActionPrediction(.noPerson)

    /// A prediction that takes the place of real prediction from the
    /// action classifier model that has a low confidence.
    /// - Tag: lowConfidencePrediction
    static let lowConfidencePrediction = ActionPrediction(.lowConfidence)

    /// Creates a prediction with an app-defined label.
    /// - Parameter otherLabel: A label defined by the application, not the
    /// action classifier model.
    /// Only the `lowConfidence()` and `noPerson()` type methods use this initializer.
    public init(_ otherLabel: AppLabel) {
        label = otherLabel.rawValue
    }

    /// A Boolean that indicates whether the label is from the action classifier model
}

enum AppLabel: String {
    case starting = "Starting Up"
    case noPerson = "No Person"
    case lowConfidence = "Low Confidence"
}
