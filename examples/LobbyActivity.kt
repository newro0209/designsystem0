//
// LobbyActivity.kt
// Example lobby screen using the game-like design system (Android)
//

package com.designsystem.examples

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.ObjectAnimator
import android.animation.PropertyValuesHolder
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.view.Gravity
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import com.designsystem.renderer.ButtonRenderer
import com.designsystem.renderer.ColorTokens

/**
 * Example lobby activity demonstrating game-like design system
 */
class LobbyActivity : AppCompatActivity() {
    
    private lateinit var playButton: ButtonRenderer
    private lateinit var settingsButton: ButtonRenderer
    private lateinit var rewardButton: ButtonRenderer
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val rootLayout = setupBackground()
        setupButtons(rootLayout)
        
        setContentView(rootLayout)
        
        // Animate entrance after layout
        rootLayout.post {
            animateEntrance()
        }
    }
    
    // MARK: - Setup
    
    private fun setupBackground(): FrameLayout {
        val layout = FrameLayout(this).apply {
            layoutParams = FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        }
        
        // Set gradient background
        val gradient = GradientDrawable(
            GradientDrawable.Orientation.TOP_BOTTOM,
            intArrayOf(
                ColorTokens.fromToken("background"),
                ColorTokens.fromToken("surface")
            )
        )
        layout.background = gradient
        
        return layout
    }
    
    private fun setupButtons(container: FrameLayout) {
        val buttonWidth = (280 * resources.displayMetrics.density).toInt()
        val buttonHeight = (60 * resources.displayMetrics.density).toInt()
        val spacing = (80 * resources.displayMetrics.density).toInt()
        
        // Create vertical layout for buttons
        val buttonLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            layoutParams = FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.CENTER
            }
        }
        
        // Play Button (Primary Action)
        playButton = ButtonRenderer(this, "PLAY NOW").apply {
            layoutParams = LinearLayout.LayoutParams(buttonWidth, buttonHeight).apply {
                bottomMargin = spacing
            }
            setOnClickListener {
                handlePlayTapped()
            }
        }
        buttonLayout.addView(playButton)
        
        // Settings Button
        settingsButton = ButtonRenderer(this, "SETTINGS").apply {
            layoutParams = LinearLayout.LayoutParams(buttonWidth, buttonHeight).apply {
                bottomMargin = spacing
            }
            setOnClickListener {
                handleSettingsTapped()
            }
        }
        buttonLayout.addView(settingsButton)
        
        // Reward Button
        rewardButton = ButtonRenderer(this, "DAILY REWARD").apply {
            layoutParams = LinearLayout.LayoutParams(buttonWidth, buttonHeight)
            setOnClickListener {
                handleRewardTapped()
            }
        }
        buttonLayout.addView(rewardButton)
        
        container.addView(buttonLayout)
    }
    
    // MARK: - Animations
    
    private fun animateEntrance() {
        // Hide buttons initially
        playButton.alpha = 0f
        settingsButton.alpha = 0f
        rewardButton.alpha = 0f
        
        playButton.scaleX = 0.8f
        playButton.scaleY = 0.8f
        settingsButton.scaleX = 0.8f
        settingsButton.scaleY = 0.8f
        rewardButton.scaleX = 0.8f
        rewardButton.scaleY = 0.8f
        
        // Animate in sequence (EnterLobby motion)
        animateButton(playButton, 100)
        animateButton(settingsButton, 200)
        animateButton(rewardButton, 300)
    }
    
    private fun animateButton(button: ButtonRenderer, delay: Long) {
        val scaleX = PropertyValuesHolder.ofFloat("scaleX", 0.8f, 1.0f)
        val scaleY = PropertyValuesHolder.ofFloat("scaleY", 0.8f, 1.0f)
        val alpha = PropertyValuesHolder.ofFloat("alpha", 0f, 1f)
        
        ObjectAnimator.ofPropertyValuesHolder(button, scaleX, scaleY, alpha).apply {
            duration = 400
            startDelay = delay
            start()
        }
    }
    
    // MARK: - Actions
    
    private fun handlePlayTapped() {
        println("🎮 Play button tapped")
        
        // Show success animation
        playButton.triggerReward()
        
        // Navigate to game after animation
        playButton.postDelayed({
            println("→ Navigate to game")
            Toast.makeText(this, "Starting game...", Toast.LENGTH_SHORT).show()
        }, 600)
    }
    
    private fun handleSettingsTapped() {
        println("⚙️ Settings button tapped")
        Toast.makeText(this, "Opening settings...", Toast.LENGTH_SHORT).show()
    }
    
    private fun handleRewardTapped() {
        println("🎁 Reward button tapped")
        
        // Simulate reward collection
        val hasReward = (0..1).random() == 1
        
        if (hasReward) {
            rewardButton.triggerReward()
            showRewardDialog()
        } else {
            rewardButton.triggerError()
            showNoRewardDialog()
        }
    }
    
    private fun showRewardDialog() {
        AlertDialog.Builder(this)
            .setTitle("🎉 Daily Reward!")
            .setMessage("You received 100 coins!")
            .setPositiveButton("Awesome!") { dialog, _ ->
                dialog.dismiss()
            }
            .show()
    }
    
    private fun showNoRewardDialog() {
        AlertDialog.Builder(this)
            .setTitle("Already Claimed")
            .setMessage("Come back tomorrow for your next reward!")
            .setPositiveButton("OK") { dialog, _ ->
                dialog.dismiss()
            }
            .show()
    }
}

/*
To use this example:

1. Create a new Android app project
2. Copy the generated Kotlin files from android/generated/
3. Copy the renderer files from android/renderer/
4. Add this LobbyActivity to your project
5. Set it as the launcher activity in AndroidManifest.xml:

<activity
    android:name=".LobbyActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LAUNCHER" />
    </intent-filter>
</activity>

6. Run the app!
*/
