//
// ButtonConfig.swift
// Auto-generated from design.yaml - DO NOT EDIT MANUALLY
//

import Foundation
import CoreGraphics

/// Configuration for Button entity
public struct ButtonConfig {
    public let type: EntityType = .interactive
    
    /// Visual configuration for each state
    public struct StateVisual {
        public let scale: CGFloat
        public let glow: CGFloat
        public let opacity: CGFloat
        public let elevation: Int?
        public let color: String?
        public let particles: Bool
        public let shake: Bool
        public let pulse: Bool
        public let blurBackground: Bool
    }

    public let stateVisuals: [EntityState: StateVisual]

    public init() {
        var visuals: [EntityState: StateVisual] = [:]

        // idle state
        visuals[.idle] = StateVisual(
            scale: 1.0,
            glow: 0.2,
            opacity: 1.0,
            elevation: nil,
            color: "primary",
            particles: false,
            shake: false,
            pulse: false,
            blurBackground: false
        )

        // focus state
        visuals[.focus] = StateVisual(
            scale: 1.05,
            glow: 0.5,
            opacity: 1.0,
            elevation: 2,
            color: nil,
            particles: false,
            shake: false,
            pulse: false,
            blurBackground: false
        )

        // pressed state
        visuals[.pressed] = StateVisual(
            scale: 0.92,
            glow: 0.8,
            opacity: 0.9,
            elevation: nil,
            color: nil,
            particles: false,
            shake: false,
            pulse: false,
            blurBackground: false
        )

        // active state
        visuals[.active] = StateVisual(
            scale: 1.0,
            glow: 0.6,
            opacity: 1.0,
            elevation: nil,
            color: "success",
            particles: false,
            shake: false,
            pulse: false,
            blurBackground: false
        )

        // rewarded state
        visuals[.rewarded] = StateVisual(
            scale: 1.15,
            glow: 1.0,
            opacity: 1.0,
            elevation: nil,
            color: nil,
            particles: true,
            shake: false,
            pulse: false,
            blurBackground: false
        )

        // error state
        visuals[.error] = StateVisual(
            scale: 1.0,
            glow: 0.3,
            opacity: 1.0,
            elevation: nil,
            color: "error",
            particles: false,
            shake: true,
            pulse: false,
            blurBackground: false
        )

        // disabled state
        visuals[.disabled] = StateVisual(
            scale: 1.0,
            glow: 0.0,
            opacity: 0.4,
            elevation: nil,
            color: nil,
            particles: false,
            shake: false,
            pulse: false,
            blurBackground: false
        )

        self.stateVisuals = visuals
    }
}

public enum EntityType {
    case interactive
    case container
    case indicator
    case navigation
}
