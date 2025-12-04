# BEOnboardingPopup 🚀

**BEOnboardingPopup** is a lightweight, highly customizable, and animated onboarding popup library for iOS, written in pure Swift (UIKit). It features a "spotlight" effect to highlight specific UI elements, guiding users through your app's features with style.

![Platform](https://img.shields.io/badge/Platform-iOS-orange.svg)
![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
![License](https://img.shields.io/badge/License-MIT-blue.svg)

<p align="center">
  <img src="https://github.com/burakekmen/BEOnboardingPopup/raw/main/BEOnboardingPopupSample/BEOnboardingPopupSample/BEOnboardingPopupSample.gif" alt="Demo Animation" width="600" />
</p>

## ✨ Features

- [x] **Spotlight Effect:** Highlights target views by dimming the background.
- [x] **Pure UIKit:** No Storyboards or XIBs, purely programmatic UI.
- [x] **Fully Customizable:** Change colors, fonts, corner radius, sizes, and more via `Theme`.
- [x] **Manager Support:** Easy-to-use Singleton Manager to handle popup flows.
- [x] **Auto Layout:** Automatically calculates positions relative to target views.
- [x] **Swift Package Manager (SPM):** Easy installation.
- [x] **iOS 15+ Support:** Supports Dark Mode and dynamic system colors.

### [Medium Article](https://medium.com/@burakekmen/building-spotlight-onboarding-flows-in-swift-with-beonboardingpopup-2fb7524a89cc)

## 📲 Installation

### Swift Package Manager

To integrate **BEOnboardingPopup** into your Xcode project using SPM:

1. Open Xcode and go to **File > Add Packages...**
2. Enter the repository URL:
   ```text
   [https://github.com/burakekmen/BEOnboardingPopup.git](https://github.com/burakekmen/BEOnboardingPopup.git)
3. Select Up to Next Major Version.
4. Click Add Package.


## 📝 SwiftUI Usage (Workaround)

```swift
import SwiftUI
import BEOnboardingPopup

struct SwiftUIExampleView: View {
    
    // 1. State variables to capture the global frames (screen coordinates) of target views.
    // Unlike UIKit, SwiftUI views don't expose a direct 'frame' property easily,
    // so we need to capture them manually using GeometryReader.
    @State private var profileFrame: CGRect = .zero
    @State private var settingsFrame: CGRect = .zero
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                
                // --- Target 1: Profile Image ---
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
                    // 2. We use a transparent overlay with GeometryReader to get the frame.
                    .overlay(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    // Capture the frame in the global screen coordinate space
                                    self.profileFrame = geo.frame(in: .global)
                                }
                        }
                    )
                
                Text("Welcome to the App!")
                    .font(.title2)
                
                // --- Target 2: Settings Button ---
                Button(action: {}) {
                    HStack {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                // Attaching the reader to the second target
                .overlay(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                self.settingsFrame = geo.frame(in: .global)
                            }
                    }
                )
                
                Spacer()
                
                // --- Trigger Button ---
                Button("Start Onboarding Tour") {
                    startOnboarding()
                }
                .font(.headline)
                .padding(.bottom, 50)
            }
            .navigationTitle("SwiftUI Demo")
        }
    }
    
    // 3. Logic to bridge SwiftUI and the UIKit Popup Library
    func startOnboarding() {
        // A. Find the Root View Controller.
        // Since BEOnboardingPopup is a UIViewController, it needs a host to be presented.
        // We access the active window scene to find the top-most controller.
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            print("Error: Could not find Root View Controller")
            return
        }
        
        // B. Prepare the steps using the captured CGRects (States).
        // Note: We act as if we are passing manual frames instead of UIView references.
        let stepsWithFrames: [(MyOnboardingStep, CGRect)] = [
            (.profile, profileFrame),
            (.settings, settingsFrame)
        ]
        
        // C. Call the Manager
        // Use the method that accepts manual frames (CGRect).
        BEOnboardingPopupManager.shared.show(
            on: rootVC,
            stepsWithFrames: stepsWithFrames,
            onFinish: {
                print("SwiftUI Onboarding Completed")
            }
        )
    }
}
```


## 🚀 Quick Start
1. Define Your Steps
Create an enum that conforms to the BEOnboardingStepable protocol. This defines the content of your popup steps.

```swift
import UIKit
import BEOnboardingPopup

enum MyOnboardingStep: BEOnboardingStepable {
    case profile
    case settings
    
    var text: String {
        switch self {
        case .profile: return "Tap here to edit your profile details."
        case .settings: return "Configure your app preferences here."
        }
    }
    
    var image: UIImage? {
        switch self {
        case .profile: return UIImage(systemName: "person.circle")
        case .settings: return UIImage(systemName: "gear")
        }
    }
}
```

2. Show the Popup
Use the BEOnboardingPopupManager to launch the onboarding flow. You don't need to calculate frames manually; just pass the UIView references!

```swift
class ViewController: UIViewController {

    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let steps: [(MyOnboardingStep, UIView)] = [
            (.profile, profileButton),
            (.settings, settingsButton)
        ]
        
        BEOnboardingPopupManager.shared.show(
            on: self,
            items: steps,
            onStepShown: { step in
                print("User is seeing: \(step)")
            },
            onFinish: {
                print("Onboarding completed!")
            }
        )
    }
}
```

## 🎨 Customization (Theming)
You can fully customize the look and feel of the popup by passing a BEOnboardingPopupTheme object.

```swift
// 1. Create a custom theme
var oceanTheme = BEOnboardingPopupTheme.default

// Layout
oceanTheme.popupWidth = 320
oceanTheme.containerCornerRadius = 16

// Colors
oceanTheme.containerBackgroundColor = UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0) // Light Blue
oceanTheme.overlayColor = UIColor.black.withAlphaComponent(0.7)

// Fonts & Text Colors
oceanTheme.descriptionColor = .systemIndigo
oceanTheme.nextButtonTextColor = .systemBlue
oceanTheme.nextButtonBorderColor = .systemBlue

// Texts
oceanTheme.nextButtonText = "Next Step"
oceanTheme.finishButtonText = "Awesome!"

// 2. Pass it to the manager
BEOnboardingPopupManager.shared.show(
    on: self,
    items: steps,
    theme: oceanTheme, // <--- Apply theme here
    onFinish: { print("Finished with Custom Theme") }
)
```

## 📱 Running the Demo
This repository includes a fully functional example project where you can play with customization settings in real-time.

Clone the repo.

Open Example/BEOnboardingPopupDemo.xcodeproj.

Select the simulator (e.g., iPhone 15).

Press Cmd + R to run.

Tap "⚙️ Configure & Test Popup" to try different themes and settings.


## 📋 Requirements
iOS 15.0+
Swift 5.0+


## 📄 License
BEOnboardingPopup is available under the MIT license. See the [LICENSE](https://github.com/burakekmen/BEOnboardingPopup/blob/main/LICENCE) file for more info.
