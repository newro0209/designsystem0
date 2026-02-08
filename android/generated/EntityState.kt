//
// EntityState.kt
// Auto-generated from design.yaml - DO NOT EDIT MANUALLY
//

package com.designsystem.core

/**
 * Universal state machine for all UI entities
 */
sealed class EntityState(val stateName: String) {
    object Idle : EntityState("idle")
    object Focus : EntityState("focus")
    object Pressed : EntityState("pressed")
    object Active : EntityState("active")
    object Rewarded : EntityState("rewarded")
    object Error : EntityState("error")
    object Disabled : EntityState("disabled")
}

// State Transitions

/**
 * Check if transition to target state is valid
 */
fun EntityState.canTransitionTo(targetState: EntityState): Boolean {
    return when (this) {
        is EntityState.Idle -> targetState in listOf(EntityState.Focus, EntityState.Pressed, EntityState.Active, EntityState.Disabled)
        is EntityState.Focus -> targetState in listOf(EntityState.Idle, EntityState.Pressed, EntityState.Disabled)
        is EntityState.Pressed -> targetState in listOf(EntityState.Idle, EntityState.Active, EntityState.Rewarded, EntityState.Error)
        is EntityState.Active -> targetState in listOf(EntityState.Idle, EntityState.Rewarded, EntityState.Disabled)
        is EntityState.Rewarded -> targetState in listOf(EntityState.Idle, EntityState.Active)
        is EntityState.Error -> targetState in listOf(EntityState.Idle)
        is EntityState.Disabled -> targetState in listOf(EntityState.Idle)
    }
}

/**
 * Transition to new state if valid
 */
fun EntityState.transitionTo(targetState: EntityState): EntityState? {
    return if (canTransitionTo(targetState)) targetState else null
}

// State Properties

/**
 * Whether this state is interactive
 */
val EntityState.isInteractive: Boolean
    get() = when (this) {
        is EntityState.Idle,
        is EntityState.Focus,
        is EntityState.Pressed,
        is EntityState.Active -> true
        else -> false
    }

/**
 * Whether this state requires animation
 */
val EntityState.requiresAnimation: Boolean
    get() = this !is EntityState.Disabled

/**
 * All possible states
 */
fun getAllStates(): List<EntityState> = listOf(
    EntityState.Idle,
    EntityState.Focus,
    EntityState.Pressed,
    EntityState.Active,
    EntityState.Rewarded,
    EntityState.Error,
    EntityState.Disabled
)
