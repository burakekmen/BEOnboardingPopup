//
//  ViewController.swift
//  BEOnboardingPopupSample
//
//  Created by Burak Ekmen on 3.12.2025.
//

import UIKit
import BEOnboardingPopup

// MARK: - 1. Demo Data (English)
enum DemoStep: BEOnboardingStepable {
    case profile
    case notifications
    case settings
    
    var text: String {
        switch self {
        case .profile: return "Tap on your profile picture to edit account details and privacy settings."
        case .notifications: return "Stay updated! Enable notifications to receive the latest news and alerts."
        case .settings: return "Need help? You can configure app preferences and themes here."
        }
    }
    
    var image: UIImage? {
        switch self {
        case .profile: return UIImage(systemName: "person.crop.circle.fill")
        case .notifications: return UIImage(systemName: "bell.fill")
        case .settings: return nil // No image for this step
        }
    }
}

// MARK: - 2. Main Screen (The Stage)
class ViewController: UIViewController {
    
    // Default theme state
    private var currentTheme: BEOnboardingPopupTheme = .default
    
    // --- Target Views ---
    private lazy var profileIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "person.circle"))
        iv.tintColor = .systemGray; iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var notificationButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "bell.fill"), for: .normal)
        btn.tintColor = .systemOrange
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var settingsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("App Settings", for: .normal)
        btn.backgroundColor = .systemGray5
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var configureButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("⚙️ Configure & Test Popup", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(navigateToSettings), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Demo Home"
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(profileIcon)
        view.addSubview(notificationButton)
        view.addSubview(settingsButton)
        view.addSubview(configureButton)
        
        NSLayoutConstraint.activate([
            // Targets placed distinctly
            profileIcon.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            profileIcon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            profileIcon.widthAnchor.constraint(equalToConstant: 44), profileIcon.heightAnchor.constraint(equalToConstant: 44),
            
            notificationButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            notificationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            notificationButton.widthAnchor.constraint(equalToConstant: 44), notificationButton.heightAnchor.constraint(equalToConstant: 44),
            
            settingsButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            settingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: 140),
            
            // Configure Button
            configureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            configureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            configureButton.widthAnchor.constraint(equalToConstant: 280),
            configureButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }
    
    @objc private func navigateToSettings() {
        let settingsVC = SettingsViewController(currentTheme: currentTheme)
        settingsVC.delegate = self
        navigationController?.pushViewController(settingsVC, animated: true)
    }
}

// MARK: - Delegate Implementation
extension ViewController: SettingsDelegate {
    func didUpdateThemeAndRun(_ theme: BEOnboardingPopupTheme) {
        self.currentTheme = theme
        
        // Wait for pop animation to finish slightly for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.startOnboarding()
        }
    }
    
    private func startOnboarding() {
        let steps: [(DemoStep, UIView)] = [
            (.profile, profileIcon),
            (.notifications, notificationButton),
            (.settings, settingsButton)
        ]
        
        BEOnboardingPopupManager.shared.show(
            on: self,
            items: steps,
            theme: currentTheme,
            onFinish: { print("Onboarding Flow Finished") }
        )
    }
}

// MARK: - 3. Settings Screen (Deep Customization)
protocol SettingsDelegate: AnyObject {
    func didUpdateThemeAndRun(_ theme: BEOnboardingPopupTheme)
}

class SettingsViewController: UIViewController {
    
    weak var delegate: SettingsDelegate?
    private var tempTheme: BEOnboardingPopupTheme
    
    // --- UI Components ---
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    // Section: Layout
    private let widthSlider = UISlider()
    private let radiusSlider = UISlider()
    private let imgHeightSlider = UISlider()
    
    // Section: Typography & Content
    private let fontSizeSlider = UISlider()
    private let nextTxtField = UITextField()
    private let backTxtField = UITextField()
    
    // Section: Colors (Simplified with Segments)
    private let bgStyleSegment = UISegmentedControl(items: ["System", "Dark", "Ocean", "Cream"])
    private let accentColorSegment = UISegmentedControl(items: ["Green", "Blue", "Orange", "Purple"])
    private let overlaySlider = UISlider()

    init(currentTheme: BEOnboardingPopupTheme) {
        self.tempTheme = currentTheme
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Customize Popup"
        setupScrollView()
        setupForm()
        loadCurrentValues()
    }
    
    private func setupScrollView() {
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
    }
    
    private func setupForm() {
        // 1. Run Button Section
        let runButton = UIButton(type: .system)
        runButton.setTitle("Apply & Run Demo", for: .normal)
        runButton.backgroundColor = .systemBlue
        runButton.setTitleColor(.white, for: .normal)
        runButton.layer.cornerRadius = 10
        runButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        runButton.addTarget(self, action: #selector(saveAndRun), for: .touchUpInside)
        stackView.addArrangedSubview(runButton)
        
        addSeparator(text: "DIMENSIONS")
        addControl(title: "Popup Width (250-350)", control: widthSlider, min: 250, max: 350)
        addControl(title: "Corner Radius (0-40)", control: radiusSlider, min: 0, max: 40)
        addControl(title: "Image Height (50-200)", control: imgHeightSlider, min: 50, max: 200)
        
        addSeparator(text: "COLORS & THEME")
        addControl(title: "Background Style", control: bgStyleSegment)
        addControl(title: "Accent Color (Buttons/Steps)", control: accentColorSegment)
        addControl(title: "Overlay Opacity (0.0 - 0.9)", control: overlaySlider, min: 0.0, max: 0.9)
        
        addSeparator(text: "TEXT & FONTS")
        addControl(title: "Font Size Scale (12-18)", control: fontSizeSlider, min: 12, max: 18)
        
        nextTxtField.borderStyle = .roundedRect; nextTxtField.placeholder = "Next Btn"
        backTxtField.borderStyle = .roundedRect; backTxtField.placeholder = "Back Btn"
        let textStack = UIStackView(arrangedSubviews: [nextTxtField, backTxtField])
        textStack.distribution = .fillEqually; textStack.spacing = 10
        addControl(title: "Button Labels", control: textStack)
    }
    
    private func loadCurrentValues() {
        widthSlider.value = Float(tempTheme.popupWidth)
        radiusSlider.value = Float(tempTheme.containerCornerRadius)
        imgHeightSlider.value = Float(tempTheme.imageHeight)
        
        var white: CGFloat = 0; var alpha: CGFloat = 0
        tempTheme.overlayColor.getWhite(&white, alpha: &alpha)
        overlaySlider.value = Float(alpha)
        
        // Font size approximation
        fontSizeSlider.value = Float(tempTheme.descriptionFont.pointSize)
        
        nextTxtField.text = tempTheme.nextButtonText
        backTxtField.text = tempTheme.backButtonText
        
        bgStyleSegment.selectedSegmentIndex = 0
        accentColorSegment.selectedSegmentIndex = 0 // Default Green/System
    }
    
    @objc private func saveAndRun() {
        // Gather Values
        tempTheme.popupWidth = CGFloat(widthSlider.value)
        tempTheme.containerCornerRadius = CGFloat(radiusSlider.value)
        tempTheme.imageHeight = CGFloat(imgHeightSlider.value)
        tempTheme.popupHeightWithImage = CGFloat(imgHeightSlider.value) + 120
        tempTheme.overlayColor = UIColor.black.withAlphaComponent(CGFloat(overlaySlider.value))
        
        if let next = nextTxtField.text, !next.isEmpty { tempTheme.nextButtonText = next }
        if let back = backTxtField.text, !back.isEmpty { tempTheme.backButtonText = back }
        
        // Apply Fonts
        let size = CGFloat(fontSizeSlider.value)
        tempTheme.descriptionFont = .systemFont(ofSize: size, weight: .regular)
        tempTheme.stepLabelFont = .systemFont(ofSize: size, weight: .regular)
        tempTheme.nextButtonFont = .systemFont(ofSize: size, weight: .bold)
        tempTheme.backButtonFont = .systemFont(ofSize: size, weight: .bold)
        
        // Apply Colors Logic
        applyColorLogic()
        
        // Notify & Pop
        navigationController?.popViewController(animated: true)
        delegate?.didUpdateThemeAndRun(tempTheme)
    }
    
    private func applyColorLogic() {
        // 1. Background
        switch bgStyleSegment.selectedSegmentIndex {
        case 1: // Dark
            tempTheme.containerBackgroundColor = UIColor(white: 0.15, alpha: 1.0)
            tempTheme.descriptionColor = .white
        case 2: // Ocean
            tempTheme.containerBackgroundColor = UIColor(red: 0.90, green: 0.96, blue: 1.0, alpha: 1.0)
            tempTheme.descriptionColor = .black
        case 3: // Cream
            tempTheme.containerBackgroundColor = UIColor(red: 1.0, green: 0.98, blue: 0.90, alpha: 1.0)
            tempTheme.descriptionColor = .brown
        default: // System
            tempTheme.containerBackgroundColor = .systemBackground
            tempTheme.descriptionColor = .label
        }
        
        // 2. Accents
        let accent: UIColor
        switch accentColorSegment.selectedSegmentIndex {
        case 1: accent = .systemBlue
        case 2: accent = .systemOrange
        case 3: accent = .systemPurple
        default: accent = .systemGreen
        }
        
        tempTheme.nextButtonTextColor = (bgStyleSegment.selectedSegmentIndex == 1) ? .white : accent
        tempTheme.nextButtonBorderColor = (bgStyleSegment.selectedSegmentIndex == 1) ? .white : accent
        tempTheme.backButtonTextColor = (bgStyleSegment.selectedSegmentIndex == 1) ? .lightGray : accent
        tempTheme.stepLabelColor = (bgStyleSegment.selectedSegmentIndex == 1) ? .lightGray : accent
    }
    
    // MARK: - UI Helpers
    private func addSeparator(text: String) {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: 13, weight: .heavy)
        lbl.textColor = .secondaryLabel
        stackView.addArrangedSubview(lbl)
    }
    
    private func addControl(title: String, control: UIView, min: Float? = nil, max: Float? = nil) {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8
        
        let lbl = UILabel()
        lbl.text = title
        lbl.font = .systemFont(ofSize: 15, weight: .medium)
        
        if let slider = control as? UISlider, let min = min, let max = max {
            slider.minimumValue = min
            slider.maximumValue = max
        }
        
        container.addArrangedSubview(lbl)
        container.addArrangedSubview(control)
        stackView.addArrangedSubview(container)
    }
}
