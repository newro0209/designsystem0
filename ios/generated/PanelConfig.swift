//
// PanelConfig.swift
// Auto-generated from design.yaml - DO NOT EDIT MANUALLY
//

import Foundation
import CoreGraphics

/// Configuration for Panel entity
public struct PanelConfig {
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
            glow: 0.0,
            opacity: 1.0,
            elevation: 2,
            color: nil,
            particles: false,
            shake: false,
            pulse: false,
            blurBackground: true
        )

        // focus state
        visuals[.focus] = StateVisual(
            scale: 1.0,
            glow: 0.0,
            opacity: 1.0,
            elevation: 3,
            color: nil,
            particles: false,
            shake: false,
            pulse: false,
            blurBackground: false
        )

        // active state
        visuals[.active] = StateVisual(
            scale: 1.0,
            glow: 0.0,
            opacity: 1.0,
            elevation: 5,
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
