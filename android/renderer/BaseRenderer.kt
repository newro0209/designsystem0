//
// BaseRenderer.kt
// Core rendering infrastructure for game-like UI (Android)
//

package com.designsystem.renderer

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.ValueAnimator
import android.content.Context
import android.graphics.*
import android.os.Build
import android.view.Choreographer
import android.view.HapticFeedbackConstants
import android.view.View
import android.view.animation.AccelerateInterpolator
import android.view.animation.DecelerateInterpolator
import android.view.animation.LinearInterpolator
import androidx.core.graphics.withSave
import com.designsystem.core.EntityState
import kotlin.math.sin

/**
 * Base renderer interface for all entities
 */
interface EntityRenderer<T> {
    val currentState: EntityState
    val config: T
    
    fun render(state: EntityState)
    fun animate(from: EntityState, to: EntityState, completion: (() -> Unit)? = null)
}

/**
 * Base implementation for Canvas-based rendering
 */
abstract class CanvasRenderer(context: Context) : View(context) {
    
    protected var scale: Float = 1.0f
    protected var opacity: Float = 1.0f
    protected var glowIntensity: Float = 0.0f
    protected var elevation: Float = 0.0f
    
    private val glowPaint = Paint().apply {
        style = Paint.Style.FILL
        maskFilter = BlurMaskFilter(20f, BlurMaskFilter.Blur.NORMAL)
    }
    
    private val contentPaint = Paint().apply {
        style = Paint.Style.FILL
        isAntiAlias = true
    }
    
    // Particle system
    private val particles = mutableListOf<Particle>()
    private var isAnimating = false
    
    // MARK: - Visual Effects
    
    protected fun drawWithGlow(canvas: Canvas, color: Int, rect: RectF, cornerRadius: Float) {
        canvas.withSave {
            // Apply scale
            val centerX = rect.centerX()
            val centerY = rect.centerY()
            canvas.scale(scale, scale, centerX, centerY)
            
            // Draw glow
            if (glowIntensity > 0) {
                glowPaint.color = color
                glowPaint.alpha = (glowIntensity * 255).toInt()
                canvas.drawRoundRect(rect, cornerRadius, cornerRadius, glowPaint)
            }
            
            // Draw content
            contentPaint.color = color
            contentPaint.alpha = (opacity * 255).toInt()
            canvas.drawRoundRect(rect, cornerRadius, cornerRadius, contentPaint)
            
            // Draw elevation shadow
            if (elevation > 0) {
                drawElevationShadow(canvas, rect, cornerRadius)
            }
        }
    }
    
    private fun drawElevationShadow(canvas: Canvas, rect: RectF, cornerRadius: Float) {
        val shadowPaint = Paint().apply {
            style = Paint.Style.FILL
            color = Color.BLACK
            alpha = (elevation * 10).toInt().coerceIn(0, 100)
            maskFilter = BlurMaskFilter(elevation * 5, BlurMaskFilter.Blur.NORMAL)
        }
        
        val shadowRect = RectF(rect)
        shadowRect.offset(0f, elevation * 2)
        canvas.drawRoundRect(shadowRect, cornerRadius, cornerRadius, shadowPaint)
    }
    
    protected fun applyShake() {
        val animator = ValueAnimator.ofFloat(0f, 1f)
        animator.duration = 400
        animator.interpolator = LinearInterpolator()
        
        val shakeValues = floatArrayOf(0f, -10f, 10f, -10f, 10f, -5f, 5f, 0f)
        
        animator.addUpdateListener { animation ->
            val fraction = animation.animatedFraction
            val index = (fraction * (shakeValues.size - 1)).toInt()
            val nextIndex = (index + 1).coerceAtMost(shakeValues.size - 1)
            val localFraction = (fraction * (shakeValues.size - 1)) - index
            
            val value = shakeValues[index] + (shakeValues[nextIndex] - shakeValues[index]) * localFraction
            translationX = value
            invalidate()
        }
        
        animator.addListener(object : AnimatorListenerAdapter() {
            override fun onAnimationEnd(animation: Animator) {
                translationX = 0f
            }
        })
        
        animator.start()
    }
    
    protected fun applyPulse() {
        if (isAnimating) return
        isAnimating = true
        
        val animator = ValueAnimator.ofFloat(1.0f, 1.05f)
        animator.duration = 1000
        animator.repeatCount = ValueAnimator.INFINITE
        animator.repeatMode = ValueAnimator.REVERSE
        animator.interpolator = DecelerateInterpolator()
        
        animator.addUpdateListener { animation ->
            scale = animation.animatedValue as Float
            invalidate()
        }
        
        animator.start()
    }
    
    protected fun stopPulse() {
        isAnimating = false
        scale = 1.0f
        invalidate()
    }
    
    // MARK: - Particle System
    
    protected fun createParticleBurst(color: Int, count: Int = 20) {
        val centerX = width / 2f
        val centerY = height / 2f
        
        repeat(count) {
            val angle = (Math.PI * 2 * it / count).toFloat()
            val velocity = 100f + (Math.random() * 50).toFloat()
            
            particles.add(
                Particle(
                    x = centerX,
                    y = centerY,
                    velocityX = Math.cos(angle.toDouble()).toFloat() * velocity,
                    velocityY = Math.sin(angle.toDouble()).toFloat() * velocity,
                    color = color,
                    life = 1.0f
                )
            )
        }
        
        startParticleAnimation()
    }
    
    private fun startParticleAnimation() {
        Choreographer.getInstance().postFrameCallback(object : Choreographer.FrameCallback {
            override fun doFrame(frameTimeNanos: Long) {
                updateParticles(frameTimeNanos / 1_000_000f)
                
                if (particles.isNotEmpty()) {
                    Choreographer.getInstance().postFrameCallback(this)
                }
            }
        })
    }
    
    private fun updateParticles(deltaTime: Float) {
        particles.removeAll { particle ->
            particle.update(deltaTime / 1000f)
            particle.life <= 0
        }
        invalidate()
    }
    
    protected fun drawParticles(canvas: Canvas) {
        val particlePaint = Paint().apply {
            style = Paint.Style.FILL
            isAntiAlias = true
        }
        
        particles.forEach { particle ->
            particlePaint.color = particle.color
            particlePaint.alpha = (particle.life * 255).toInt()
            canvas.drawCircle(particle.x, particle.y, 5f, particlePaint)
        }
    }
    
    // MARK: - Animation Helpers
    
    protected fun animateProperty(
        from: Float,
        to: Float,
        duration: Long,
        update: (Float) -> Unit,
        completion: (() -> Unit)? = null
    ) {
        val animator = ValueAnimator.ofFloat(from, to)
        animator.duration = duration
        animator.interpolator = DecelerateInterpolator()
        
        animator.addUpdateListener { animation ->
            update(animation.animatedValue as Float)
            invalidate()
        }
        
        animator.addListener(object : AnimatorListenerAdapter() {
            override fun onAnimationEnd(animation: Animator) {
                completion?.invoke()
            }
        })
        
        animator.start()
    }
    
    // MARK: - Haptic Feedback
    
    protected fun triggerHaptic(type: Int) {
        performHapticFeedback(type)
    }
}

/**
 * Particle data class
 */
private data class Particle(
    var x: Float,
    var y: Float,
    val velocityX: Float,
    val velocityY: Float,
    val color: Int,
    var life: Float
) {
    fun update(deltaTime: Float) {
        x += velocityX * deltaTime
        y += velocityY * deltaTime
        life -= deltaTime
    }
}

/**
 * Color utility extensions
 */
object ColorTokens {
    fun fromToken(token: String): Int {
        return when (token) {
            "primary" -> Color.parseColor("#6366F1")
            "secondary" -> Color.parseColor("#8B5CF6")
            "success" -> Color.parseColor("#10B981")
            "error" -> Color.parseColor("#EF4444")
            "warning" -> Color.parseColor("#F59E0B")
            "background" -> Color.parseColor("#0F172A")
            "surface" -> Color.parseColor("#1E293B")
            "text_primary" -> Color.parseColor("#F8FAFC")
            "text_secondary" -> Color.parseColor("#94A3B8")
            else -> Color.WHITE
        }
    }
}
