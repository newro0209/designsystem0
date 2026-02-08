# API Reference

## YAML Specification

### Structure

```yaml
version: string
name: string
tokens: {...}
state_machine: {...}
entities: {...}
motions: {...}
feedback: {...}
rendering: {...}
```

### Tokens

#### Colors
```yaml
tokens:
  colors:
    primary: "#6366F1"        # Hex color code
    secondary: "#8B5CF6"
    # ... more colors
```

#### Motion Timing (milliseconds)
```yaml
tokens:
  motion:
    fast: 120          # Quick interactions
    normal: 240        # Standard animations
    emphasis: 400      # Important transitions
    slow: 600          # Dramatic effects
```

#### Elevation (z-index levels)
```yaml
tokens:
  elevation:
    z0: 0
    z1: 1
    z2: 2
    # ... up to z5
```

### State Machine

```yaml
state_machine:
  states:
    - idle
    - focus
    - pressed
    - active
    - rewarded
    - error
    - disabled
  
  transitions:
    - from: idle
      to: [focus, pressed, active, disabled]
```

### Entities

```yaml
entities:
  entity_name:
    type: interactive | container | indicator | navigation
    states:
      state_name:
        visual:
          scale: float          # 0.0 to 2.0
          glow: float           # 0.0 to 1.0
          opacity: float        # 0.0 to 1.0
          elevation: string     # "z0" to "z5"
          color: string         # Token name
          particles: boolean
          shake: boolean
          pulse: boolean
          blur_background: boolean
        animation:
          duration: string      # "motion.fast" | "motion.normal" | etc
          curve: string         # "easeIn" | "easeOut" | "spring" | etc
        feedback:
          haptic: string        # "light" | "medium" | "heavy" | "rigid"
          sound: string         # Sound effect name
```

### Motions

```yaml
motions:
  MotionName:
    description: string
    duration: string
    curve: string
    effects:
      - type: string          # "scale" | "opacity" | "translateX" | etc
        from: any
        to: any
```

### Feedback

```yaml
feedback:
  haptic:
    intensity_name:
      ios: string            # iOS API name
      android: string        # Android constant name
  
  sound:
    sound_name:
      file: string           # Audio file name
      volume: float          # 0.0 to 1.0
```

## iOS API

### EntityState (Enum)

```swift
enum EntityState: String, CaseIterable
```

#### Cases
- `idle`: Default resting state
- `focus`: Highlighted/hovering
- `pressed`: Being pressed
- `active`: Currently active/selected
- `rewarded`: Success animation
- `error`: Error state
- `disabled`: Inactive

#### Methods

```swift
func canTransition(to targetState: EntityState) -> Bool
```
Check if transition to target state is valid.

**Parameters:**
- `targetState`: The state to transition to

**Returns:** `true` if transition is allowed

```swift
func transition(to targetState: EntityState) -> EntityState?
```
Attempt to transition to new state.

**Parameters:**
- `targetState`: The state to transition to

**Returns:** New state if valid, `nil` if invalid

#### Properties

```swift
var isInteractive: Bool { get }
```
Whether this state is interactive.

```swift
var requiresAnimation: Bool { get }
```
Whether this state requires animation.

### EntityRenderer (Protocol)

```swift
protocol EntityRenderer: AnyObject {
    associatedtype ConfigType
    
    var layer: CALayer { get }
    var currentState: EntityState { get set }
    var config: ConfigType { get }
    
    func render(for state: EntityState)
    func animate(from: EntityState, to: EntityState, completion: (() -> Void)?)
}
```

### CALayerRenderer (Class)

```swift
class CALayerRenderer
```

Base class for CALayer-based rendering.

#### Properties

```swift
let rootLayer: CALayer
```
Root layer for rendering.

#### Methods

```swift
func applyGlow(intensity: CGFloat, color: UIColor = .white)
```
Apply glow effect using shadow.

**Parameters:**
- `intensity`: Glow intensity (0.0 to 1.0)
- `color`: Glow color

```swift
func applyScale(_ scale: CGFloat)
```
Apply scale transform.

```swift
func applyOpacity(_ opacity: CGFloat)
```
Apply opacity.

```swift
func applyElevation(_ elevation: Int)
```
Apply elevation (z-position).

```swift
func applyShake()
```
Apply shake animation.

```swift
func applyPulse(duration: CFTimeInterval = 1.0)
```
Apply continuous pulse animation.

```swift
func stopPulse()
```
Stop pulse animation.

```swift
func createParticleBurst(color: UIColor = .yellow, count: Int = 20)
```
Create particle burst effect.

**Parameters:**
- `color`: Particle color
- `count`: Number of particles

### GameButton (UIView)

```swift
class GameButton: UIView
```

UIView wrapper for ButtonRenderer.

#### Initializers

```swift
init(frame: CGRect, title: String)
```
Create a game button.

**Parameters:**
- `frame`: Button frame
- `title`: Button text

#### Methods

```swift
func onTap(_ handler: @escaping () -> Void)
```
Set tap handler.

**Parameters:**
- `handler`: Closure to call on tap

```swift
func showReward()
```
Trigger reward animation.

```swift
func showError()
```
Trigger error animation.

### UIColor Extensions

```swift
static func from(token: String) -> UIColor
```
Get color from token name.

**Parameters:**
- `token`: Token name (e.g., "primary")

**Returns:** UIColor

```swift
convenience init(hex: String)
```
Create color from hex string.

**Parameters:**
- `hex`: Hex color code (e.g., "#6366F1")

## Android API

### EntityState (Sealed Class)

```kotlin
sealed class EntityState(val stateName: String)
```

#### Objects
- `Idle`: Default resting state
- `Focus`: Highlighted/hovering
- `Pressed`: Being pressed
- `Active`: Currently active/selected
- `Rewarded`: Success animation
- `Error`: Error state
- `Disabled`: Inactive

#### Extension Functions

```kotlin
fun EntityState.canTransitionTo(targetState: EntityState): Boolean
```
Check if transition to target state is valid.

**Parameters:**
- `targetState`: The state to transition to

**Returns:** `true` if transition is allowed

```kotlin
fun EntityState.transitionTo(targetState: EntityState): EntityState?
```
Attempt to transition to new state.

**Parameters:**
- `targetState`: The state to transition to

**Returns:** New state if valid, `null` if invalid

#### Extension Properties

```kotlin
val EntityState.isInteractive: Boolean
```
Whether this state is interactive.

```kotlin
val EntityState.requiresAnimation: Boolean
```
Whether this state requires animation.

### EntityRenderer (Interface)

```kotlin
interface EntityRenderer<T> {
    val currentState: EntityState
    val config: T
    
    fun render(state: EntityState)
    fun animate(from: EntityState, to: EntityState, completion: (() -> Unit)? = null)
}
```

### CanvasRenderer (Abstract Class)

```kotlin
abstract class CanvasRenderer(context: Context) : View(context)
```

Base class for Canvas-based rendering.

#### Properties

```kotlin
protected var scale: Float
protected var opacity: Float
protected var glowIntensity: Float
protected var elevation: Float
```

#### Methods

```kotlin
protected fun drawWithGlow(
    canvas: Canvas,
    color: Int,
    rect: RectF,
    cornerRadius: Float
)
```
Draw shape with glow effect.

**Parameters:**
- `canvas`: Canvas to draw on
- `color`: Shape color
- `rect`: Rectangle bounds
- `cornerRadius`: Corner radius

```kotlin
protected fun applyShake()
```
Apply shake animation.

```kotlin
protected fun applyPulse()
```
Apply continuous pulse animation.

```kotlin
protected fun stopPulse()
```
Stop pulse animation.

```kotlin
protected fun createParticleBurst(color: Int, count: Int = 20)
```
Create particle burst effect.

**Parameters:**
- `color`: Particle color (Int color value)
- `count`: Number of particles

```kotlin
protected fun triggerHaptic(type: Int)
```
Trigger haptic feedback.

**Parameters:**
- `type`: HapticFeedbackConstants value

### ButtonRenderer (Class)

```kotlin
class ButtonRenderer(context: Context, title: String) : CanvasRenderer(context)
```

Button renderer using Canvas API.

#### Methods

```kotlin
override fun render(state: EntityState)
```
Render button in specified state.

```kotlin
override fun animate(
    from: EntityState,
    to: EntityState,
    completion: (() -> Unit)? = null
)
```
Animate transition between states.

```kotlin
fun triggerReward()
```
Trigger reward animation.

```kotlin
fun triggerError()
```
Trigger error animation.

```kotlin
fun setOnClickListener(handler: () -> Unit)
```
Set click handler.

**Parameters:**
- `handler`: Function to call on click

### ColorTokens (Object)

```kotlin
object ColorTokens {
    fun fromToken(token: String): Int
}
```

Get color from token name.

**Parameters:**
- `token`: Token name (e.g., "primary")

**Returns:** Int color value

## Usage Examples

### iOS Example

```swift
import UIKit

// Create button
let button = GameButton(
    frame: CGRect(x: 50, y: 100, width: 200, height: 60),
    title: "Click Me"
)

// Handle tap
button.onTap {
    print("Button tapped!")
    button.showReward()
}

// Add to view
view.addSubview(button)

// Manual state control
let renderer = button.renderer
renderer.handleFocus()        // Show focus state
renderer.handleTouchDown()    // Show pressed state
renderer.handleTouchUp()      // Return to idle
renderer.triggerReward()      // Show reward animation
renderer.triggerError()       // Show error animation
```

### Android Example

```kotlin
import com.designsystem.renderer.ButtonRenderer

// Create button
val button = ButtonRenderer(context, "Click Me").apply {
    layoutParams = ViewGroup.LayoutParams(600, 200)
}

// Handle click
button.setOnClickListener {
    println("Button tapped!")
    button.triggerReward()
}

// Add to layout
layout.addView(button)

// Manual state control
button.handleFocus()       // Show focus state
button.triggerReward()     // Show reward animation
button.triggerError()      // Show error animation
```

### Custom State Transitions

```swift
// iOS
let currentState: EntityState = .idle

if let newState = currentState.transition(to: .focus) {
    renderer.animate(from: currentState, to: newState) {
        print("Animation complete")
    }
}
```

```kotlin
// Android
val currentState: EntityState = EntityState.Idle

currentState.transitionTo(EntityState.Focus)?.let { newState ->
    renderer.animate(currentState, newState) {
        println("Animation complete")
    }
}
```

## Configuration

### Entity Config Structure (Generated)

#### Swift
```swift
struct ButtonConfig {
    struct StateVisual {
        let scale: CGFloat
        let glow: CGFloat
        let opacity: CGFloat
        let elevation: Int?
        let color: String?
        let particles: Bool
        let shake: Bool
        let pulse: Bool
        let blurBackground: Bool
    }
    
    let stateVisuals: [EntityState: StateVisual]
}
```

#### Kotlin
```kotlin
class ButtonConfig {
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
    
    val stateVisuals: Map<EntityState, StateVisual>
}
```

## Animation Timing

From `spec/design.yaml`:

```yaml
motion:
  fast: 120ms       # Quick feedback
  normal: 240ms     # Standard transitions
  emphasis: 400ms   # Important changes
  slow: 600ms       # Dramatic effects
```

## Haptic Feedback Mapping

### iOS
- `light` → `UIImpactFeedbackGenerator.light`
- `medium` → `UIImpactFeedbackGenerator.medium`
- `heavy` → `UIImpactFeedbackGenerator.heavy`
- `rigid` → `UIImpactFeedbackGenerator.rigid`

### Android
- `light` → `HapticFeedbackConstants.KEYBOARD_TAP`
- `medium` → `HapticFeedbackConstants.VIRTUAL_KEY`
- `heavy` → `HapticFeedbackConstants.LONG_PRESS`
- `rigid` → `HapticFeedbackConstants.REJECT`

## Error Handling

### Invalid State Transitions

```swift
// iOS
let invalid = EntityState.disabled.transition(to: .rewarded)
// Returns nil - disabled can't transition to rewarded
```

```kotlin
// Android
val invalid = EntityState.Disabled.transitionTo(EntityState.Rewarded)
// Returns null - disabled can't transition to rewarded
```

### Graceful Fallbacks

Renderers handle missing configurations gracefully:
- Missing state visuals: No-op
- Invalid colors: Falls back to white
- Missing elevation: Defaults to 0

## Performance Considerations

### iOS
- CALayer rendering is hardware-accelerated
- Animations run on separate thread
- Particle limit: 20-50 for optimal performance

### Android
- Hardware acceleration enabled by default
- Choreographer ensures frame-perfect animations
- Particle limit: 20-50 for optimal performance

## Thread Safety

### iOS
- All UI operations must be on main thread
- Use `DispatchQueue.main.async` for updates from background

### Android
- All UI operations must be on main thread
- Use `runOnUiThread` or `post` for updates from background
