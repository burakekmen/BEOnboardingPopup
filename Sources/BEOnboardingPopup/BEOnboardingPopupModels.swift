//
//  BEOnboardingPopupModels.swift
//  BEOnboardingPopup
//
//  Created by Burak Ekmen on 3.12.2025.
//

import UIKit

public protocol BEOnboardingStepable {
    var text: String { get }
    var image: UIImage? { get }
}

public struct BEOnboardingPopupTextModel {
    public let text: String
    public let font: UIFont?
    public let color: UIColor?
    public init(text: String, font: UIFont? = nil, color: UIColor? = nil) {
        self.text = text
        self.font = font
        self.color = color
    }
}

public struct BEOnboardingPopupModel {
    public let image: UIImage?
    public let description: BEOnboardingPopupTextModel
    public var targetFrame: CGRect
    public init(image: UIImage? = nil, description: BEOnboardingPopupTextModel, targetFrame: CGRect) {
        self.image = image
        self.description = description
        self.targetFrame = targetFrame
    }
}
