//
// BaseRenderer.swift
// Core rendering infrastructure for game-like UI
//

import UIKit
import CoreAnimation
import MetalKit

/// Base renderer protocol for all entities
public protocol EntityRenderer: AnyObject {
    associatedtype ConfigType
    
    var layer: CALayer { get }
    var currentState: EntityState { get set }
    var config: ConfigType { get }
    
    func render(for state: EntityState)
    func animate(from: EntityState, to: EntityState, completion: (() -> Void)?)
}

/// Base implementation for CALayer-based rendering
open class CALayerRenderer {
    public let rootLayer: CALayer
    private var glowLayer: CALayer?
    private var particleLayer: CAEmitterLayer?
    
    public init(frame: CGRect) {
        self.rootLayer = CALayer()
        self.rootLayer.frame = frame
        setupLayers()
    }
    
    private func setupLayers() {
        rootLayer.masksToBounds = false
        rootLayer.allowsGroupOpacity = true
    }
    
    // MARK: - Visual Effects
    
    /// Apply glow effect using shadow
    public func applyGlow(intensity: CGFloat, color: UIColor = .white) {
        rootLayer.shadowColor = color.cgColor
        rootLayer.shadowRadius = 20 * intensity
        rootLayer.shadowOpacity = Float(intensity)
        rootLayer.shadowOffset = .zero
    }
    
    /// Apply scale transform
    public func applyScale(_ scale: CGFloat) {
        rootLayer.transform = CATransform3DMakeScale(scale, scale, 1.0)
    }
    
    /// Apply opacity
    public func applyOpacity(_ opacity: CGFloat) {
        rootLayer.opacity = Float(opacity)
    }
    
    /// Apply elevation (z-index)
    public func applyElevation(_ elevation: Int) {
        rootLayer.zPosition = CGFloat(elevation) * 10
    }
    
    /// Apply shake animation
    public func applyShake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.values = [0, -10, 10, -10, 10, -5, 5, 0]
        animation.keyTimes = [0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 1]
        animation.duration = 0.4
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        rootLayer.add(animation, forKey: "shake")
    }
    
    /// Apply pulse animation
    public func applyPulse(duration: CFTimeInterval = 1.0) {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.05
        scaleAnimation.duration = duration
        scaleAnimation.autoreverses = true
        scaleAnimation.repeatCount = .infinity
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        rootLayer.add(scaleAnimation, forKey: "pulse")
    }
    
    /// Stop pulse animation
    public func stopPulse() {
        rootLayer.removeAnimation(forKey: "pulse")
    }
    
    // MARK: - Particle System
    
    /// Create particle burst effect
    public func createParticleBurst(color: UIColor = .yellow, count: Int = 20) {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
        emitter.emitterShape = .circle
        emitter.emitterSize = CGSize(width: 10, height: 10)
        
        let cell = CAEmitterCell()
        cell.contents = createParticleImage(color: color)?.cgImage
        cell.birthRate = Float(count)
        cell.lifetime = 1.0
        cell.velocity = 100
        cell.velocityRange = 50
        cell.emissionRange = .pi * 2
        cell.spin = 2
        cell.spinRange = 3
        cell.scaleRange = 0.3
        cell.alphaSpeed = -1.0
        
        emitter.emitterCells = [cell]
        rootLayer.addSublayer(emitter)
        
        // Remove after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            emitter.removeFromSuperlayer()
        }
    }
    
    private func createParticleImage(color: UIColor) -> UIImage? {
        let size = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    // MARK: - Animation Helpers
    
    public func animateProperty<T>(
        keyPath: String,
        from fromValue: T,
        to toValue: T,
        duration: CFTimeInterval,
        curve: CAMediaTimingFunctionName = .easeInEaseOut,
        completion: (() -> Void)? = nil
    ) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: curve)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        rootLayer.add(animation, forKey: keyPath)
        rootLayer.setValue(toValue, forKey: keyPath)
        
        CATransaction.commit()
    }
}

// MARK: - Metal Glow Renderer

/// Metal-based glow effect renderer for high-performance visual effects
public class MetalGlowRenderer {
    private let device: MTLDevice?
    private let commandQueue: MTLCommandQueue?
    
    public init() {
        self.device = MTLCreateSystemDefaultDevice()
        self.commandQueue = device?.makeCommandQueue()
    }
    
    public func renderGlow(intensity: CGFloat, color: UIColor, size: CGSize) -> UIImage? {
        // Placeholder for Metal shader implementation
        // In production, this would compile and run Metal shaders
        return nil
    }
}

// MARK: - Animation Curves

public extension CAMediaTimingFunctionName {
    static let spring = CAMediaTimingFunctionName(rawValue: "spring")
    static let bounceOut = CAMediaTimingFunctionName(rawValue: "bounceOut")
}

// MARK: - Color Extensions

public extension UIColor {
    static func from(token: String) -> UIColor {
        switch token {
        case "primary": return UIColor(hex: "#6366F1")
        case "secondary": return UIColor(hex: "#8B5CF6")
        case "success": return UIColor(hex: "#10B981")
        case "error": return UIColor(hex: "#EF4444")
        case "warning": return UIColor(hex: "#F59E0B")
        case "background": return UIColor(hex: "#0F172A")
        case "surface": return UIColor(hex: "#1E293B")
        case "text_primary": return UIColor(hex: "#F8FAFC")
        case "text_secondary": return UIColor(hex: "#94A3B8")
        default: return .white
        }
    }
    
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
