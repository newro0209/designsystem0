//
// ButtonConfig.kt
// Auto-generated from design.yaml - DO NOT EDIT MANUALLY
//

package com.designsystem.entities

import com.designsystem.core.EntityState

/**
 * Configuration for Button entity
 */
class ButtonConfig {
    val type: EntityType = EntityType.INTERACTIVE
    
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
            glow = 0.2f,
            opacity = 1.0f,
            elevation = null,
            color = "primary",
            particles = false,
            shake = false,
            pulse = false,
            blurBackground = false
        ),
        EntityState.Focus to StateVisual(
            scale = 1.05f,
            glow = 0.5f,
            opacity = 1.0f,
            elevation = 2,
            color = null,
            particles = false,
            shake = false,
            pulse = false,
            blurBackground = false
        ),
        EntityState.Pressed to StateVisual(
            scale = 0.92f,
            glow = 0.8f,
            opacity = 0.9f,
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
            color = "success",
            particles = false,
            shake = false,
            pulse = false,
            blurBackground = false
        ),
        EntityState.Rewarded to StateVisual(
            scale = 1.15f,
            glow = 1.0f,
            opacity = 1.0f,
            elevation = null,
            color = null,
            particles = true,
            shake = false,
            pulse = false,
            blurBackground = false
        ),
        EntityState.Error to StateVisual(
            scale = 1.0f,
            glow = 0.3f,
            opacity = 1.0f,
            elevation = null,
            color = "error",
            particles = false,
            shake = true,
            pulse = false,
            blurBackground = false
        ),
        EntityState.Disabled to StateVisual(
            scale = 1.0f,
            glow = 0.0f,
            opacity = 0.4f,
            elevation = null,
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
