//
// EnergyBarConfig.kt
// Auto-generated from design.yaml - DO NOT EDIT MANUALLY
//

package com.designsystem.entities

import com.designsystem.core.EntityState

/**
 * Configuration for EnergyBar entity
 */
class EnergyBarConfig {
    val type: EntityType = EntityType.INDICATOR
    
    /**
     * Visual configuration for a state
     */
    data class StateVisual(
        val scale: Float = 1.0f,
        val glow: Float = 0.0f,
        val opacity: Float = 1.0f,
        val elevation: Int? = null,
        val color: String? = null,
        val particles: Boolean = false,
        val shake: Boolean = false,
        val pulse: Boolean = false,
        val blurBackground: Boolean = false
    )
    
    val stateVisuals: Map<EntityState, StateVisual> = mapOf(
        EntityState.Idle to StateVisual(
            scale = 1.0f,
            glow = 0.3f,
            opacity = 1.0f,
            elevation = null,
            color = null,
            particles = false,
            shake = false,
            pulse = false,
            blurBackground = false
        ),
        EntityState.Active to StateVisual(
            scale = 1.0f,
            glow = 0.6f,
            opacity = 1.0f,
            elevation = null,
            color = null,
            particles = false,
            shake = false,
            pulse = true,
            blurBackground = false
        ),
        EntityState.Error to StateVisual(
            scale = 1.0f,
            glow = 0.5f,
            opacity = 1.0f,
            elevation = null,
            color = "error",
            particles = false,
            shake = true,
            pulse = false,
            blurBackground = false
        ),
    )
}

enum class EntityType {
    INTERACTIVE,
    CONTAINER,
    INDICATOR,
    NAVIGATION
}
