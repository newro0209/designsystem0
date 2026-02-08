//
// CardConfig.kt
// Auto-generated from design.yaml - DO NOT EDIT MANUALLY
//

package com.designsystem.entities

import com.designsystem.core.EntityState

/**
 * Configuration for Card entity
 */
class CardConfig {
    val type: EntityType = EntityType.CONTAINER
    
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
            glow = 0.1f,
            opacity = 1.0f,
            elevation = 1,
            color = null,
            particles = false,
            shake = false,
            pulse = false,
            blurBackground = false
        ),
        EntityState.Focus to StateVisual(
            scale = 1.03f,
            glow = 0.4f,
            opacity = 1.0f,
            elevation = 3,
            color = null,
            particles = false,
            shake = false,
            pulse = false,
            blurBackground = false
        ),
        EntityState.Pressed to StateVisual(
            scale = 0.98f,
            glow = 0.2f,
            opacity = 1.0f,
            elevation = 2,
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
            elevation = 4,
            color = null,
            particles = false,
            shake = false,
            pulse = false,
            blurBackground = false
        ),
        EntityState.Disabled to StateVisual(
            scale = 1.0f,
            glow = 0.0f,
            opacity = 0.5f,
            elevation = 0,
            color = null,
            particles = false,
            shake = false,
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
