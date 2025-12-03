//
//  BEOnboardingPopupManager.swift
//  BEOnboardingPopup
//
//  Created by Burak Ekmen on 3.12.2025.
//

import UIKit

@MainActor
public final class BEOnboardingPopupManager {
    public static let shared = BEOnboardingPopupManager()
    private init() {}
    private weak var currentPopup: BEOnboardingPopupViewController?

    public func show<Step: BEOnboardingStepable>(
        on presentingVC: UIViewController,
        items: [(step: Step, targetView: UIView)],
        theme: BEOnboardingPopupTheme = .default,
        onStepShown: ((_ step: Step) -> Void)? = nil,
        onFinish: @escaping () -> Void) {
        let stepsWithFrames = items.map { (step, view) -> (step: Step, frame: CGRect) in
            let absoluteFrame = view.convert(view.bounds, to: nil)
            return (step, absoluteFrame)
        }
        
        guard !stepsWithFrames.isEmpty, currentPopup == nil else { return }

        let models = stepsWithFrames.map { (data) -> BEOnboardingPopupModel in
            return BEOnboardingPopupModel(
                image: data.step.image,
                description: BEOnboardingPopupTextModel(text: data.step.text),
                targetFrame: data.frame
            )
        }
        
        let steps = stepsWithFrames.map { $0.step }

        let popupVC = BEOnboardingPopupViewController(
            models: models,
            theme: theme,
            onFinish: { [weak self] in
                self?.currentPopup = nil
                onFinish()
            },
            onStepShown: { index in
                guard steps.indices.contains(index) else { return }
                onStepShown?(steps[index])
            }
        )

        currentPopup = popupVC
        presentingVC.present(popupVC, animated: true)
    }
}
