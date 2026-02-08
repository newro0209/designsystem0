//
// EntityState.swift
// Auto-generated from design.yaml - DO NOT EDIT MANUALLY
//

import Foundation

/// Universal state machine for all UI entities
public enum EntityState: String, CaseIterable {
    case idle
    case focus
    case pressed
    case active
    case rewarded
    case error
    case disabled
}

// MARK: - State Transitions

public extension EntityState {
    /// Check if transition to target state is valid
    func canTransition(to targetState: EntityState) -> Bool {
        switch self {
        case .idle:
            return [.focus, .pressed, .active, .disabled].contains(targetState)
        case .focus:
            return [.idle, .pressed, .disabled].contains(targetState)
        case .pressed:
            return [.idle, .active, .rewarded, .error].contains(targetState)
        case .active:
            return [.idle, .rewarded, .disabled].contains(targetState)
        case .rewarded:
            return [.idle, .active].contains(targetState)
        case .error:
            return [.idle].contains(targetState)
        case .disabled:
            return [.idle].contains(targetState)
        }
    }
    
    /// Transition to new state if valid
    func transition(to targetState: EntityState) -> EntityState? {
        return canTransition(to: targetState) ? targetState : nil
    }
}

// MARK: - State Properties

public extension EntityState {
    /// Whether this state is interactive
    var isInteractive: Bool {
        switch self {
        case .idle, .focus, .pressed, .active:
            return true
        case .rewarded, .error, .disabled:
            return false
        }
    }
    
    /// Whether this state requires animation
    var requiresAnimation: Bool {
        return self != .disabled
    }
}
