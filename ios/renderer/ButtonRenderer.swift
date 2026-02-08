//
// ButtonRenderer.swift
// Button entity renderer using CALayer
//

import UIKit
import CoreAnimation

public class ButtonRenderer: CALayerRenderer, EntityRenderer {
    public typealias ConfigType = ButtonConfig
    
    public var layer: CALayer { rootLayer }
    public var currentState: EntityState = .idle
    public let config: ButtonConfig
    
    private let contentLayer: CAShapeLayer
    private let labelLayer: CATextLayer
    
    public init(frame: CGRect, title: String) {
        self.config = ButtonConfig()
        self.contentLayer = CAShapeLayer()
        self.labelLayer = CATextLayer()
        
        super.init(frame: frame)
        
        setupContentLayer(frame: frame)
        setupLabelLayer(title: title, frame: frame)
        
        // Apply initial state
        render(for: .idle)
    }
    
    private func setupContentLayer(frame: CGRect) {
        contentLayer.frame = rootLayer.bounds
        contentLayer.path = UIBezierPath(
            roundedRect: rootLayer.bounds,
            cornerRadius: frame.height / 2
        ).cgPath
        contentLayer.fillColor = UIColor.from(token: "primary").cgColor
        contentLayer.strokeColor = UIColor.white.withAlphaComponent(0.2).cgColor
        contentLayer.lineWidth = 2
        
        rootLayer.addSublayer(contentLayer)
    }
    
    private func setupLabelLayer(title: String, frame: CGRect) {
        labelLayer.frame = rootLayer.bounds
        labelLayer.string = title
        labelLayer.fontSize = 18
        labelLayer.foregroundColor = UIColor.from(token: "text_primary").cgColor
        labelLayer.alignmentMode = .center
        labelLayer.contentsScale = UIScreen.main.scale
        
        let fontName = "System-Bold" as CFString
        let font = CTFontCreateWithName(fontName, 18, nil)
        labelLayer.font = font
        
        // Center vertically
        let textHeight: CGFloat = 22
        labelLayer.frame = CGRect(
            x: 0,
            y: (frame.height - textHeight) / 2,
            width: frame.width,
            height: textHeight
        )
        
        rootLayer.addSublayer(labelLayer)
    }
    
    // MARK: - EntityRenderer Protocol
    
    public func render(for state: EntityState) {
        guard let visual = config.stateVisuals[state] else { return }
        
        // Apply visual properties
        applyScale(visual.scale)
        applyOpacity(visual.opacity)
        applyGlow(intensity: visual.glow)
        
        if let elevation = visual.elevation {
            applyElevation(elevation)
        }
        
        // Apply color
        if let colorToken = visual.color {
            contentLayer.fillColor = UIColor.from(token: colorToken).cgColor
        }
        
        // Apply special effects
        if visual.shake {
            applyShake()
        }
        
        if visual.particles {
            createParticleBurst(color: .yellow, count: 20)
        }
        
        if visual.pulse {
            applyPulse()
        } else {
            stopPulse()
        }
        
        currentState = state
    }
    
    public func animate(from fromState: EntityState, to toState: EntityState, completion: (() -> Void)? = nil) {
        guard let toVisual = config.stateVisuals[toState] else {
            completion?()
            return
        }
        
        // Determine animation duration (in seconds)
        let duration: CFTimeInterval = 0.24 // motion.normal from spec
        
        // Determine timing function
        let curve: CAMediaTimingFunctionName
        switch toState {
        case .pressed:
            curve = .easeIn
        case .focus:
            curve = .easeInEaseOut
        case .rewarded, .active:
            curve = .easeOut // In production, use custom spring
        default:
            curve = .easeOut
        }
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: curve))
        CATransaction.setCompletionBlock {
            self.render(for: toState)
            completion?()
        }
        
        // Animate scale
        let currentScale = (rootLayer.value(forKeyPath: "transform.scale") as? CGFloat) ?? 1.0
        animateProperty(
            keyPath: "transform.scale",
            from: currentScale,
            to: toVisual.scale,
            duration: duration,
            curve: curve
        )
        
        // Animate opacity
        animateProperty(
            keyPath: "opacity",
            from: rootLayer.opacity,
            to: Float(toVisual.opacity),
            duration: duration,
            curve: curve
        )
        
        // Animate glow (shadow opacity)
        animateProperty(
            keyPath: "shadowOpacity",
            from: rootLayer.shadowOpacity,
            to: Float(toVisual.glow),
            duration: duration,
            curve: curve
        )
        
        // Update glow properties
        applyGlow(intensity: toVisual.glow)
        
        CATransaction.commit()
        
        currentState = toState
    }
    
    // MARK: - Interaction
    
    public func handleTouchDown() {
        if let newState = currentState.transition(to: .pressed) {
            animate(from: currentState, to: newState)
            triggerHaptic(style: .light)
        }
    }
    
    public func handleTouchUp() {
        if let newState = currentState.transition(to: .idle) {
            animate(from: currentState, to: newState)
        }
    }
    
    public func handleFocus() {
        if let newState = currentState.transition(to: .focus) {
            animate(from: currentState, to: newState)
        }
    }
    
    public func handleUnfocus() {
        if let newState = currentState.transition(to: .idle) {
            animate(from: currentState, to: newState)
        }
    }
    
    public func triggerReward() {
        if let newState = currentState.transition(to: .rewarded) {
            animate(from: currentState, to: newState) {
                // Auto-return to idle after reward animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    if let idleState = self.currentState.transition(to: .idle) {
                        self.animate(from: self.currentState, to: idleState)
                    }
                }
            }
            triggerHaptic(style: .heavy)
        }
    }
    
    public func triggerError() {
        if let newState = currentState.transition(to: .error) {
            animate(from: currentState, to: newState) {
                // Auto-return to idle after error animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    if let idleState = self.currentState.transition(to: .idle) {
                        self.animate(from: self.currentState, to: idleState)
                    }
                }
            }
            triggerHaptic(style: .rigid)
        }
    }
    
    // MARK: - Haptic Feedback
    
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

// MARK: - UIView Wrapper

/// UIView wrapper for ButtonRenderer
public class GameButton: UIView {
    private let renderer: ButtonRenderer
    private var touchHandler: (() -> Void)?
    
    public init(frame: CGRect, title: String) {
        self.renderer = ButtonRenderer(frame: frame, title: title)
        super.init(frame: frame)
        
        layer.addSublayer(renderer.layer)
        setupGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        addGestureRecognizer(longPress)
    }
    
    @objc private func handleTap() {
        renderer.handleTouchDown()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            self.renderer.handleTouchUp()
            self.touchHandler?()
        }
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            renderer.handleTouchDown()
        case .ended, .cancelled:
            renderer.handleTouchUp()
        default:
            break
        }
    }
    
    public func onTap(_ handler: @escaping () -> Void) {
        self.touchHandler = handler
    }
    
    public func showReward() {
        renderer.triggerReward()
    }
    
    public func showError() {
        renderer.triggerError()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        renderer.layer.frame = bounds
    }
}
