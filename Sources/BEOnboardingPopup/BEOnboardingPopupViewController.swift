//
//  BEOnboardingPopupViewController.swift
//  BEOnboardingPopup
//
//  Created by Burak Ekmen on 3.12.2025.
//

import UIKit

public final class BEOnboardingPopupViewController: UIViewController {
    private let models: [BEOnboardingPopupModel]
    private let theme: BEOnboardingPopupTheme
    private var currentIndex: Int = 0
    private let onFinish: () -> Void
    private let onStepShown: ((_ index: Int) -> Void)?

    // Layout Constraints
    private var containerTopConstraint: NSLayoutConstraint?
    private var containerLeadingConstraint: NSLayoutConstraint?
    private var containerWidthConstraint: NSLayoutConstraint?
    private var containerHeightConstraint: NSLayoutConstraint?
    private var nextButtonWidthConstraint: NSLayoutConstraint?
    private var imageViewHeightConstraint: NSLayoutConstraint?

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = theme.containerBackgroundColor
        view.layer.cornerRadius = theme.containerCornerRadius
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.85
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var stepLabel: UILabel = {
        let label = UILabel()
        label.font = theme.stepLabelFont
        label.textColor = theme.stepLabelColor
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = theme.nextButtonFont
        button.setTitleColor(theme.nextButtonTextColor, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = theme.nextButtonBorderColor.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        return button
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = theme.backButtonFont
        button.setTitleColor(theme.backButtonTextColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }()

    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = theme.overlayColor
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        view.addGestureRecognizer(tap)
        return view
    }()

    private let maskLayer = CAShapeLayer()

    public init(models: [BEOnboardingPopupModel], theme: BEOnboardingPopupTheme = .default, onFinish: @escaping () -> Void, onStepShown: ((_ index: Int) -> Void)? = nil) {
        self.models = models
        self.theme = theme
        self.onFinish = onFinish
        self.onStepShown = onStepShown
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Configures the initial view hierarchy, background, and starts the first step.
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupOverlay()
        setupUI()
        updateStep(animated: false)
    }

    /// Updates the overlay frame and spotlight path when the view layout changes (e.g., device rotation).
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        overlayView.frame = view.bounds
        if models.indices.contains(currentIndex) {
            updateSpotlight(for: models[currentIndex].targetFrame)
        }
    }
    
    /// Configures the dimmed background layer and sets up the CAShapeLayer for the mask effect.
    private func setupOverlay() {
        overlayView.frame = view.bounds
        view.insertSubview(overlayView, at: 0)
        view.addSubview(containerView)
        maskLayer.fillRule = .evenOdd
        overlayView.layer.mask = maskLayer
    }

    /// Adds subviews to the container and applies the initial Auto Layout constraints.
    private func setupUI() {
        [imageView, descriptionLabel, stepLabel, nextButton, backButton].forEach { containerView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: nextButton.topAnchor, constant: -12),

            nextButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            nextButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            nextButton.heightAnchor.constraint(equalToConstant: 33),
            
            backButton.centerYAnchor.constraint(equalTo: nextButton.centerYAnchor),
            backButton.trailingAnchor.constraint(equalTo: nextButton.leadingAnchor, constant: -15),
            
            stepLabel.centerYAnchor.constraint(equalTo: nextButton.centerYAnchor),
            stepLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12)
        ])
        
        imageViewHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: theme.imageHeight)
        imageViewHeightConstraint?.isActive = true
        
        nextButtonWidthConstraint = nextButton.widthAnchor.constraint(equalToConstant: 65)
        nextButtonWidthConstraint?.isActive = true
        
        containerWidthConstraint = containerView.widthAnchor.constraint(equalToConstant: theme.popupWidth)
        containerHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: theme.popupHeightWithImage)
        containerLeadingConstraint = containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)
        containerTopConstraint = containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        
        NSLayoutConstraint.activate([
            containerWidthConstraint!, containerHeightConstraint!, containerLeadingConstraint!, containerTopConstraint!
        ])
        
        stepLabel.isHidden = models.count == 1
    }

    /// Handles the "Next" button tap. Advances to the next step or dismisses the popup if it's the last step.
    @objc private func nextTapped() {
        if currentIndex < models.count - 1 { currentIndex += 1; updateStep(animated: true) } else { dismiss(animated: true) { [weak self] in self?.onFinish() } }
    }
    
    /// Handles the "Back" button tap. Returns to the previous step.
    @objc private func backTapped() { guard currentIndex > 0 else { return }; currentIndex -= 1; updateStep(animated: true) }
    
    /// Handles taps on the dimmed background area. Functions as a "Next" action for better UX.
    @objc private func overlayTapped() { nextTapped() }
}


private extension BEOnboardingPopupViewController {
    
    /// Creates a cut-out "hole" in the overlay layer to highlight the specified target frame.
    /// - Parameter targetFrame: The frame of the UI element to be highlighted.
    private func updateSpotlight(for targetFrame: CGRect) {
        let path = UIBezierPath(rect: view.bounds)
        let hole = UIBezierPath(roundedRect: targetFrame, cornerRadius: 12)
        path.append(hole)
        maskLayer.path = path.cgPath
        animatePopup(around: targetFrame)
    }

    /// Calculates the optimal position for the popup (above, below, or center) relative to the target and animates the layout changes.
    /// - Parameter targetFrame: The frame of the highlighted element to position the popup around.
    private func animatePopup(around targetFrame: CGRect) {
        let screenBounds = view.bounds
        let popupWidth = theme.popupWidth
        let hasImage = models[currentIndex].image != nil
        let popupHeight = hasImage ? theme.popupHeightWithImage : theme.popupHeightWithoutImage
        let canShowBelow = targetFrame.maxY + popupHeight + 12 < screenBounds.height
        let canShowAbove = targetFrame.minY - popupHeight - 12 > 0

        let yOffset: CGFloat = canShowBelow ? targetFrame.maxY + 12 : (canShowAbove ? targetFrame.minY - popupHeight - 12 : screenBounds.midY - popupHeight / 2)
        let popupX = min(max(targetFrame.midX - popupWidth / 2, 12), screenBounds.width - popupWidth - 12)

        containerWidthConstraint?.constant = popupWidth
        containerHeightConstraint?.constant = popupHeight
        containerLeadingConstraint?.constant = popupX
        containerTopConstraint?.constant = yOffset
        imageViewHeightConstraint?.constant = hasImage ? theme.imageHeight : 0

        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }
    
    /// Updates the UI content (text, image, buttons) for the current step index and triggers the spotlight animation.
    /// - Parameter animated: Determines if the layout update should be animated.
    func updateStep(animated: Bool) {
        guard models.indices.contains(currentIndex) else { return }
        let model = models[currentIndex]
        
        imageView.image = model.image
        descriptionLabel.font = model.description.font ?? theme.descriptionFont
        descriptionLabel.textColor = model.description.color ?? theme.descriptionColor
        descriptionLabel.text = model.description.text
        
        let stepText = "*\(currentIndex + 1)*/\(models.count)"
        stepLabel.attributedText = parseBoldText(text: stepText, separator: "*", boldFont: .systemFont(ofSize: 15, weight: .bold), boldColor: theme.stepLabelColor)

        backButton.isHidden = currentIndex == 0
        backButton.setTitle(theme.backButtonText, for: .normal)
        
        let buttonText = (models.count == 1 || currentIndex == models.count - 1) ? theme.finishButtonText : theme.nextButtonText
        nextButton.setTitle(buttonText, for: .normal)
        
        let textWidth = buttonText.size(withAttributes: [.font: theme.nextButtonFont]).width
        nextButtonWidthConstraint?.constant = max(65, textWidth + 32)
        
        let generator = UIImpactFeedbackGenerator(style: .light); generator.impactOccurred()
        updateSpotlight(for: model.targetFrame)
        onStepShown?(currentIndex)
    }
    
    /// Helper method to create an attributed string with bold text between specific separators.
    func parseBoldText(text: String, separator: String, boldFont: UIFont, boldColor: UIColor) -> NSAttributedString {
        let parts = text.components(separatedBy: separator); let attr = NSMutableAttributedString()
        for (i, p) in parts.enumerated() {
            attr.append(NSAttributedString(string: p, attributes: [.font: i % 2 != 0 ? boldFont : stepLabel.font!, .foregroundColor: i % 2 != 0 ? boldColor : stepLabel.textColor!]))
        }
        return attr
    }
    
}
