//
//  SettingsViewController.swift
//  BEOnboardingPopupSample
//
//  Created by Burak Ekmen on 4.12.2025.
//

import UIKit
import BEOnboardingPopup

protocol SettingsDelegate: AnyObject {
    func didFinishConfiguring(with theme: BEOnboardingPopupTheme)
}

class SettingsViewController: UIViewController {
    
    weak var delegate: SettingsDelegate?
    private var theme: BEOnboardingPopupTheme
    
    // --- UI Controls ---
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    // Sliders
    private let widthSlider = UISlider()
    private let radiusSlider = UISlider()
    private let overlaySlider = UISlider()
    
    // Segmented Controls
    private let themeSegment = UISegmentedControl(items: ColorTheme.allCases.map { $0.title })
    
    // Text Fields
    private let nextField = UITextField()
    private let backField = UITextField()
    
    init(initialTheme: BEOnboardingPopupTheme) {
        self.theme = initialTheme
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        title = "Customization"
        setupLayout()
        populateInitialValues()
    }
    
    private func setupLayout() {
        // Setup ScrollView and StackView
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 40, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // 1. Action Button
        var runConfig = UIButton.Configuration.filled()
        runConfig.title = "✅ Apply & Preview"
        runConfig.baseBackgroundColor = .systemGreen
        runConfig.buttonSize = .large
        let runBtn = UIButton(configuration: runConfig)
        runBtn.addTarget(self, action: #selector(applyAndRun), for: .touchUpInside)
        stackView.addArrangedSubview(runBtn)
        
        addHeader("APPEARANCE & DIMENSIONS")
        addControl("Width (260 - 340)", control: widthSlider, min: 260, max: 340)
        addControl("Corner Radius (0 - 30)", control: radiusSlider, min: 0, max: 30)
        addControl("Overlay Opacity (0.1 - 0.9)", control: overlaySlider, min: 0.1, max: 0.9)
        
        addHeader("COLOR THEME")
        themeSegment.addTarget(self, action: #selector(themeSegmentChanged), for: .valueChanged)
        stackView.addArrangedSubview(themeSegment)
        
        addHeader("TEXTS")
        let textStack = UIStackView(arrangedSubviews: [nextField, backField])
        textStack.spacing = 12; textStack.distribution = .fillEqually
        nextField.borderStyle = .roundedRect; nextField.placeholder = "Next Button Text"
        backField.borderStyle = .roundedRect; backField.placeholder = "Back Button Text"
        stackView.addArrangedSubview(textStack)
    }
    
    private func populateInitialValues() {
        widthSlider.value = Float(theme.popupWidth)
        radiusSlider.value = Float(theme.containerCornerRadius)
        
        var white: CGFloat = 0, alpha: CGFloat = 0
        theme.overlayColor.getWhite(&white, alpha: &alpha)
        overlaySlider.value = Float(alpha)
        
        nextField.text = theme.nextButtonText
        backField.text = theme.backButtonText
        themeSegment.selectedSegmentIndex = 0
    }
    
    @objc private func themeSegmentChanged() {
        // No immediate action on segment change, will apply on button press
    }
    
    @objc private func applyAndRun() {
        // 1. Get Slider Values
        theme.popupWidth = CGFloat(widthSlider.value)
        theme.containerCornerRadius = CGFloat(radiusSlider.value)
        theme.overlayColor = UIColor.black.withAlphaComponent(CGFloat(overlaySlider.value))
        
        // 2. Get Texts
        if let next = nextField.text, !next.isEmpty { theme.nextButtonText = next }
        if let back = backField.text, !back.isEmpty { theme.backButtonText = back }
        
        // 3. Apply Selected Color Theme
        if let selectedColorTheme = ColorTheme(rawValue: themeSegment.selectedSegmentIndex) {
            selectedColorTheme.apply(to: &theme)
        }
        
        // 4. Dismiss and Notify Main Screen
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.didFinishConfiguring(with: self.theme)
        }
    }
    
    // UI Helpers
    private func addHeader(_ text: String) {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: 13, weight: .heavy)
        lbl.textColor = .secondaryLabel
        stackView.setCustomSpacing(24, after: stackView.arrangedSubviews.last ?? stackView)
        stackView.addArrangedSubview(lbl)
        stackView.setCustomSpacing(8, after: lbl)
    }
    
    private func addControl(_ title: String, control: UISlider, min: Float, max: Float) {
        let lbl = UILabel(); lbl.text = title; lbl.font = .systemFont(ofSize: 14)
        control.minimumValue = min; control.maximumValue = max
        stackView.addArrangedSubview(lbl)
        stackView.addArrangedSubview(control)
    }
}
