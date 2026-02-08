//
// ButtonRenderer.kt
// Button entity renderer using Canvas
//

package com.designsystem.renderer

import android.content.Context
import android.graphics.*
import android.view.HapticFeedbackConstants
import android.view.MotionEvent
import com.designsystem.core.EntityState
import com.designsystem.entities.ButtonConfig

/**
 * Button renderer using Canvas API
 */
class ButtonRenderer(
    context: Context,
    private val title: String
) : CanvasRenderer(context), EntityRenderer<ButtonConfig> {
    
    override var currentState: EntityState = EntityState.Idle
    override val config: ButtonConfig = ButtonConfig()
    
    private val buttonRect = RectF()
    private val textPaint = Paint().apply {
        style = Paint.Style.FILL
        isAntiAlias = true
        textAlign = Paint.Align.CENTER
        textSize = 18f * resources.displayMetrics.density
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        color = ColorTokens.fromToken("text_primary")
    }
    
    private var buttonColor: Int = ColorTokens.fromToken("primary")
    private var touchHandler: (() -> Unit)? = null
    
    init {
        // Enable layer for proper alpha blending
        setLayerType(LAYER_TYPE_SOFTWARE, null)
        
        // Apply initial state
        render(EntityState.Idle)
    }
    
    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        
        val padding = 20f
        buttonRect.set(
            padding,
            padding,
            w.toFloat() - padding,
            h.toFloat() - padding
        )
    }
    
    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        
        // Draw button background with glow
        val cornerRadius = buttonRect.height() / 2
        drawWithGlow(canvas, buttonColor, buttonRect, cornerRadius)
        
        // Draw text
        val textX = buttonRect.centerX()
        val textY = buttonRect.centerY() - (textPaint.descent() + textPaint.ascent()) / 2
        
        textPaint.alpha = (opacity * 255).toInt()
        canvas.drawText(title, textX, textY, textPaint)
        
        // Draw particles if any
        drawParticles(canvas)
    }
    
    // MARK: - EntityRenderer Protocol
    
    override fun render(state: EntityState) {
        val visual = config.stateVisuals[state] ?: return
        
        // Apply visual properties
        scale = visual.scale
        opacity = visual.opacity
        glowIntensity = visual.glow
        elevation = visual.elevation?.toFloat() ?: 0f
        
        // Apply color
        visual.color?.let {
            buttonColor = ColorTokens.fromToken(it)
        }
        
        // Apply special effects
        if (visual.shake) {
            applyShake()
        }
        
        if (visual.particles) {
            createParticleBurst(Color.YELLOW, 20)
        }
        
        if (visual.pulse) {
            applyPulse()
        } else {
            stopPulse()
        }
        
        currentState = state
        invalidate()
    }
    
    override fun animate(from: EntityState, to: EntityState, completion: (() -> Unit)?) {
        val toVisual = config.stateVisuals[to] ?: run {
            completion?.invoke()
            return
        }
        
        // Determine animation duration (in milliseconds)
        val duration = 240L // motion.normal from spec
        
        // Animate scale
        animateProperty(scale, toVisual.scale, duration, { scale = it })
        
        // Animate opacity
        animateProperty(opacity, toVisual.opacity, duration, { opacity = it })
        
        // Animate glow
        animateProperty(glowIntensity, toVisual.glow, duration, { glowIntensity = it }) {
            render(to)
            completion?.invoke()
        }
        
        currentState = to
    }
    
    // MARK: - Touch Handling
    
    override fun onTouchEvent(event: MotionEvent): Boolean {
        when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                handleTouchDown()
                return true
            }
            MotionEvent.ACTION_UP -> {
                handleTouchUp()
                touchHandler?.invoke()
                return true
            }
            MotionEvent.ACTION_CANCEL -> {
                handleTouchUp()
                return true
            }
        }
        return super.onTouchEvent(event)
    }
    
    private fun handleTouchDown() {
        currentState.transitionTo(EntityState.Pressed)?.let { newState ->
            animate(currentState, newState)
            triggerHaptic(HapticFeedbackConstants.KEYBOARD_TAP)
        }
    }
    
    private fun handleTouchUp() {
        currentState.transitionTo(EntityState.Idle)?.let { newState ->
            animate(currentState, newState)
        }
    }
    
    fun handleFocus() {
        currentState.transitionTo(EntityState.Focus)?.let { newState ->
            animate(currentState, newState)
        }
    }
    
    fun handleUnfocus() {
        currentState.transitionTo(EntityState.Idle)?.let { newState ->
            animate(currentState, newState)
        }
    }
    
    fun triggerReward() {
        currentState.transitionTo(EntityState.Rewarded)?.let { newState ->
            animate(currentState, newState) {
                // Auto-return to idle after reward animation
                postDelayed({
                    currentState.transitionTo(EntityState.Idle)?.let { idleState ->
                        animate(currentState, idleState)
                    }
                }, 600)
            }
            triggerHaptic(HapticFeedbackConstants.LONG_PRESS)
        }
    }
    
    fun triggerError() {
        currentState.transitionTo(EntityState.Error)?.let { newState ->
            animate(currentState, newState) {
                // Auto-return to idle after error animation
                postDelayed({
                    currentState.transitionTo(EntityState.Idle)?.let { idleState ->
                        animate(currentState, idleState)
                    }
                }, 400)
            }
            triggerHaptic(HapticFeedbackConstants.REJECT)
        }
    }
    
    // MARK: - Public API
    
    fun setOnClickListener(handler: () -> Unit) {
        this.touchHandler = handler
    }
}
