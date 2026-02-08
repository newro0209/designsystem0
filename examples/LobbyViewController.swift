//
// LobbyViewController.swift
// Example lobby screen using the game-like design system
//

import UIKit

class LobbyViewController: UIViewController {
    
    // MARK: - UI Components
    private var playButton: GameButton!
    private var settingsButton: GameButton!
    private var rewardButton: GameButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupButtons()
        animateEntrance()
    }
    
    // MARK: - Setup
    
    private func setupBackground() {
        // Set dark background
        view.backgroundColor = UIColor.from(token: "background")
        
        // Add gradient overlay
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.from(token: "background").cgColor,
            UIColor.from(token: "surface").cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupButtons() {
        let buttonWidth: CGFloat = 280
        let buttonHeight: CGFloat = 60
        let centerX = view.bounds.width / 2 - buttonWidth / 2
        let spacing: CGFloat = 80
        
        // Play Button (Primary Action)
        playButton = GameButton(
            frame: CGRect(x: centerX, y: 300, width: buttonWidth, height: buttonHeight),
            title: "PLAY NOW"
        )
        playButton.onTap { [weak self] in
            self?.handlePlayTapped()
        }
        view.addSubview(playButton)
        
        // Settings Button
        settingsButton = GameButton(
            frame: CGRect(x: centerX, y: 300 + spacing, width: buttonWidth, height: buttonHeight),
            title: "SETTINGS"
        )
        settingsButton.onTap { [weak self] in
            self?.handleSettingsTapped()
        }
        view.addSubview(settingsButton)
        
        // Reward Button
        rewardButton = GameButton(
            frame: CGRect(x: centerX, y: 300 + spacing * 2, width: buttonWidth, height: buttonHeight),
            title: "DAILY REWARD"
        )
        rewardButton.onTap { [weak self] in
            self?.handleRewardTapped()
        }
        view.addSubview(rewardButton)
    }
    
    // MARK: - Animations
    
    private func animateEntrance() {
        // Hide buttons initially
        playButton.alpha = 0
        settingsButton.alpha = 0
        rewardButton.alpha = 0
        
        playButton.transform = CGAffineTransform(scaleX: 0.8, sy: 0.8)
        settingsButton.transform = CGAffineTransform(scaleX: 0.8, sy: 0.8)
        rewardButton.transform = CGAffineTransform(scaleX: 0.8, sy: 0.8)
        
        // Animate in sequence (EnterLobby motion)
        UIView.animate(
            withDuration: 0.4,
            delay: 0.1,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.playButton.alpha = 1.0
            self.playButton.transform = .identity
        }
        
        UIView.animate(
            withDuration: 0.4,
            delay: 0.2,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.settingsButton.alpha = 1.0
            self.settingsButton.transform = .identity
        }
        
        UIView.animate(
            withDuration: 0.4,
            delay: 0.3,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.rewardButton.alpha = 1.0
            self.rewardButton.transform = .identity
        }
    }
    
    // MARK: - Actions
    
    private func handlePlayTapped() {
        print("🎮 Play button tapped")
        
        // Show success animation
        playButton.showReward()
        
        // Navigate to game after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // Navigate to game screen
            print("→ Navigate to game")
        }
    }
    
    private func handleSettingsTapped() {
        print("⚙️ Settings button tapped")
        
        // Navigate to settings
        print("→ Navigate to settings")
    }
    
    private func handleRewardTapped() {
        print("🎁 Reward button tapped")
        
        // Simulate reward collection
        let hasReward = Bool.random()
        
        if hasReward {
            rewardButton.showReward()
            showRewardPopup()
        } else {
            rewardButton.showError()
            showNoRewardMessage()
        }
    }
    
    private func showRewardPopup() {
        let alert = UIAlertController(
            title: "🎉 Daily Reward!",
            message: "You received 100 coins!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Awesome!", style: .default))
        present(alert, animated: true)
    }
    
    private func showNoRewardMessage() {
        let alert = UIAlertController(
            title: "Already Claimed",
            message: "Come back tomorrow for your next reward!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - App Entry Point

/*
To use this example:

1. Create a new iOS app project
2. Copy the generated Swift files from ios/generated/
3. Copy the renderer files from ios/renderer/
4. Replace your ViewController with this LobbyViewController
5. Run the app!

Example AppDelegate.swift or SceneDelegate.swift:

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = LobbyViewController()
        window.makeKeyAndVisible()
        self.window = window
    }
}
*/
