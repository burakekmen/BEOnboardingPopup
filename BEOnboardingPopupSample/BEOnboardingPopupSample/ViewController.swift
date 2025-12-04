//
//  ViewController.swift
//  BEOnboardingPopupSample
//
//  Created by Burak Ekmen on 3.12.2025.
//

import UIKit
import BEOnboardingPopup

enum DemoStep: BEOnboardingStepable {
    case profile, notifications, upgrades, settings
    
    var text: String {
        switch self {
        case .profile: return "Tap on your profile picture to edit personal details and account settings."
        case .notifications: return "Turn on notifications to get instant updates on new features and campaigns!"
        case .upgrades: return "You can use this section to upgrade to Premium features."
        case .settings: return "App settings, themes, and logout options are located here."
        }
    }
    
    var image: UIImage? {
        switch self {
        case .profile: return UIImage(systemName: "person.crop.circle.fill")
        case .notifications: return UIImage(systemName: "bell.badge.fill")
        case .upgrades: return UIImage(systemName: "star.circle.fill")
        case .settings: return nil // Example of a step without an image
        }
    }
}

// Pre-defined Color Themes
enum ColorTheme: Int, CaseIterable {
    case system, ocean, sunset, dark
    
    var title: String {
        switch self {
        case .system: return "System (Default)"
        case .ocean: return "Ocean Blue"
        case .sunset: return "Sunset"
        case .dark: return "Dark Mode"
        }
    }
    
    @MainActor
    func apply(to theme: inout BEOnboardingPopupTheme) {
        switch self {
        case .system:
            theme.containerBackgroundColor = .systemBackground
            theme.descriptionColor = .label
            theme.nextButtonTextColor = .systemBlue
            theme.nextButtonBorderColor = .systemBlue
            
        case .ocean:
            theme.containerBackgroundColor = UIColor(red: 0.92, green: 0.96, blue: 1.0, alpha: 1.0)
            theme.descriptionColor = UIColor(red: 0.0, green: 0.2, blue: 0.4, alpha: 1.0)
            theme.nextButtonTextColor = UIColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 1.0)
            theme.nextButtonBorderColor = theme.nextButtonTextColor
            
        case .sunset:
            theme.containerBackgroundColor = UIColor(red: 1.0, green: 0.95, blue: 0.9, alpha: 1.0)
            theme.descriptionColor = UIColor(red: 0.4, green: 0.2, blue: 0.0, alpha: 1.0)
            theme.nextButtonTextColor = .systemOrange
            theme.nextButtonBorderColor = .systemOrange
            
        case .dark:
            theme.containerBackgroundColor = UIColor(white: 0.15, alpha: 1.0)
            theme.descriptionColor = .white
            theme.nextButtonTextColor = .white
            theme.nextButtonBorderColor = .white
            theme.backButtonTextColor = .lightGray
            theme.stepLabelColor = .lightGray
        }
        
        // Adjust back button color for non-system/dark themes
        if self != .system && self != .dark {
            theme.backButtonTextColor = theme.nextButtonTextColor.withAlphaComponent(0.7)
            theme.stepLabelColor = theme.nextButtonTextColor.withAlphaComponent(0.7)
        }
    }
}

class ViewController: UIViewController {
    
    // Store current theme state
    private var currentTheme: BEOnboardingPopupTheme = .default

    // --- Target UI Elements ---
    
    // profileBarItem
    private lazy var profileButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "person.circle"), for: .normal)
        return btn
    }()

    private lazy var profileBarItem: UIBarButtonItem = {
        return UIBarButtonItem(customView: profileButton)
    }()
    
    // notificationBarItem
    private lazy var notificationButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "bell"), for: .normal)
        return btn
    }()

    private lazy var notificationBarItem: UIBarButtonItem = {
        return UIBarButtonItem(customView: notificationButton)
    }()

    private lazy var upgradeCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemYellow.withAlphaComponent(0.2)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemYellow.cgColor
        
        let icon = UIImageView(image: UIImage(systemName: "star.fill"))
        icon.tintColor = .systemOrange
        let lbl = UILabel(); lbl.text = "Go Premium"; lbl.font = .boldSystemFont(ofSize: 16)
        
        let stack = UIStackView(arrangedSubviews: [icon, lbl]); stack.spacing = 10; stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([stack.centerXAnchor.constraint(equalTo: view.centerXAnchor), stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
        return view
    }()
    
    private lazy var settingsButton: UIButton = {
        var config = UIButton.Configuration.tinted()
        config.title = "Settings"
        config.image = UIImage(systemName: "gearshape")
        config.imagePadding = 8
        config.cornerStyle = .medium
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var configureButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "🎨 Customize & Preview"
        config.baseBackgroundColor = .systemIndigo
        config.cornerStyle = .capsule
        config.buttonSize = .large
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Home"
        setupUI()
    }
    
    private func setupUI() {
        // Navbar buttons (Targets 1 & 2)
        navigationItem.rightBarButtonItems = [profileBarItem, notificationBarItem]
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .camera) // Just decoration
        
        view.addSubview(upgradeCardView)
        view.addSubview(settingsButton)
        view.addSubview(configureButton)
        
        upgradeCardView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Target 3: A card in the center
            upgradeCardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            upgradeCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            upgradeCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            upgradeCardView.heightAnchor.constraint(equalToConstant: 80),
            
            // Target 4: A button below
            settingsButton.topAnchor.constraint(equalTo: upgradeCardView.bottomAnchor, constant: 150),
            settingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Trigger Button
            configureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            configureButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            configureButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            configureButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    @objc private func openSettings() {
        let settingsVC = SettingsViewController(initialTheme: currentTheme)
        settingsVC.delegate = self
        
        // iOS 15+ Modern Sheet Presentation
        if let sheet = settingsVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium // Allow interaction with background
        }
        present(settingsVC, animated: true)
    }
}

// Handle updates from Settings Screen
extension ViewController: SettingsDelegate {
    func didFinishConfiguring(with theme: BEOnboardingPopupTheme) {
        self.currentTheme = theme
        
        var availableSteps: [(DemoStep, UIView)] = []
        
        if profileButton.window != nil {
            availableSteps.append((.profile, profileButton))
        }
        
        if notificationButton.window != nil {
            availableSteps.append((.notifications, notificationButton))
        }
        
        availableSteps.append((.upgrades, upgradeCardView))
        availableSteps.append((.settings, settingsButton))
        
        guard !availableSteps.isEmpty else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            BEOnboardingPopupManager.shared.show(
                on: self,
                items: availableSteps,
                theme: self.currentTheme,
                onFinish: {
                    print("Demo finished.")
                }
            )
        }
        
    }
}
