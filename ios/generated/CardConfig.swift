//
// CardConfig.swift
// Auto-generated from design.yaml - DO NOT EDIT MANUALLY
//

import Foundation
import CoreGraphics

/// Configuration for Card entity
public struct CardConfig {
    public let type: EntityType = .container
    
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
            glow: 0.1,
            opacity: 1.0,
            elevation: 1,
            color: nil,
            particles: false,
            shake: false,
            pulse: false,
            blurBackground: false
        )

        // focus state
        visuals[.focus] = StateVisual(
            scale: 1.03,
            glow: 0.4,
            opacity: 1.0,
            elevation: 3,
            color: nil,
            particles: false,
            shake: false,
            pulse: false,
            blurBackground: false
        )

        // pressed state
        visuals[.pressed] = StateVisual(
            scale: 0.98,
            glow: 0.2,
            opacity: 1.0,
            elevation: 2,
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
            elevation: 4,
            color: nil,
            particles: false,
            shake: false,
            pulse: false,
            blurBackground: false
        )

        // disabled state
        visuals[.disabled] = StateVisual(
            scale: 1.0,
            glow: 0.0,
            opacity: 0.5,
            elevation: 0,
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
