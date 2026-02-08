# 🎮 Game-Like Design System

A mobile-first design system that brings game UI aesthetics and interactions to iOS and Android applications. Built on a single source of truth (YAML specification) with platform-native renderers.

## 🏗️ Architecture

```
Design Spec (YAML)
   ├─ Tokens (colors, spacing, motion)
   ├─ Entities (UI components)
   ├─ Motions (animations)
   └─ Feedback (haptic, sound)
        ↓ (codegen)
iOS Renderer              Android Renderer
(Swift + CALayer/Metal)  (Kotlin + Canvas/Shader)
```

## ✨ Key Features

- **Platform Native**: 100% native iOS (Swift/CALayer/Metal) and Android (Kotlin/Canvas)
- **Game-Like UI**: Glow effects, particles, smooth animations
- **Single Source of Truth**: YAML specification drives all code generation
- **State Machine**: Universal state management (idle → focus → pressed → active → rewarded → error → disabled)
- **Motion Library**: Predefined animations that work identically on both platforms
- **Haptic & Sound**: Integrated feedback system

## 📁 Project Structure

```
designsystem0/
├── spec/
│   └── design.yaml              # Single source of truth
├── codegen/
│   └── generator.py             # Code generator
├── ios/
│   ├── generated/               # Auto-generated Swift code
│   └── renderer/                # iOS renderer implementations
│       ├── BaseRenderer.swift
│       └── ButtonRenderer.swift
├── android/
│   ├── generated/               # Auto-generated Kotlin code
│   └── renderer/                # Android renderer implementations
│       ├── BaseRenderer.kt
│       └── ButtonRenderer.kt
├── examples/                    # Usage examples
└── docs/                        # Documentation
```

## 🚀 Quick Start

### 1. Modify the Design Specification

Edit `spec/design.yaml` to customize tokens, entities, and motions:

```yaml
tokens:
  colors:
    primary: "#6366F1"
    secondary: "#8B5CF6"
  motion:
    fast: 120
    normal: 240
    emphasis: 400

entities:
  button:
    states:
      idle:
        visual:
          scale: 1.0
          glow: 0.2
      pressed:
        visual:
          scale: 0.92
          glow: 0.8
        feedback:
          haptic: light
          sound: tap
```

### 2. Generate Code

Run the code generator to create platform-specific state machines:

```bash
python3 codegen/generator.py
```

This generates:
- `ios/generated/EntityState.swift`
- `ios/generated/*Config.swift`
- `android/generated/EntityState.kt`
- `android/generated/*Config.kt`

### 3. Use in Your App

#### iOS (Swift)

```swift
import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a game-like button
        let button = GameButton(
            frame: CGRect(x: 100, y: 200, width: 200, height: 60),
            title: "Play Now"
        )
        
        button.onTap {
            print("Button tapped!")
            button.showReward() // Trigger reward animation
        }
        
        view.addSubview(button)
    }
}
```

#### Android (Kotlin)

```kotlin
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.designsystem.renderer.ButtonRenderer

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Create a game-like button
        val button = ButtonRenderer(this, "Play Now").apply {
            layoutParams = ViewGroup.LayoutParams(600, 200)
            
            setOnClickListener {
                println("Button tapped!")
                triggerReward() // Trigger reward animation
            }
        }
        
        setContentView(button)
    }
}
```

## 🎯 Core Entities

### 1. Button
Interactive button with game-like visual feedback.

**States**: idle, focus, pressed, active, rewarded, error, disabled

**Features**:
- Glow effect
- Scale animation
- Particle burst on reward
- Shake on error
- Haptic feedback

### 2. Card
Floating card container with elevation effects.

**States**: idle, focus, pressed, active, disabled

**Features**:
- Dynamic elevation
- Focus animations
- Smooth transitions

### 3. Panel
Full-screen or modal panel container.

**States**: idle, focus, active

**Features**:
- Background blur
- Rise-up animation
- High elevation

### 4. Energy Bar
Progress/status indicator.

**States**: idle, active, error

**Features**:
- Animated fill
- Pulse effect
- Error state with shake

### 5. HUD Navigation
Heads-up display navigation.

**States**: idle, focus

**Features**:
- Always on top (z5)
- Background blur
- Smooth transitions

## 🎨 State Machine

All entities follow a universal state machine:

```
idle → focus → pressed → active → rewarded → error → disabled
  ↑      ↓        ↓        ↓         ↓        ↓        ↓
  └──────┴────────┴────────┴─────────┴────────┴────────┘
```

**State Descriptions**:
- `idle`: Default resting state
- `focus`: Highlighted/hovering (keyboard or pointer)
- `pressed`: Being pressed/touched
- `active`: Currently active/selected
- `rewarded`: Success/reward animation state
- `error`: Error/failure state
- `disabled`: Inactive/unavailable

## 🎬 Motion Library

Predefined animations that work identically on both platforms:

### EnterLobby
Screen entrance with zoom and fade effect.

### FocusCard
Card elevation and scale on focus.

### OpenPanel
Panel opening with slide-up and fade.

### RewardBurst
Celebration animation with particles and rotation.

### ErrorShake
Horizontal shake with color change.

## 🔊 Feedback System

### Haptic Feedback

**iOS**:
- `light`: UIImpactFeedbackGenerator.light
- `medium`: UIImpactFeedbackGenerator.medium
- `heavy`: UIImpactFeedbackGenerator.heavy
- `rigid`: UIImpactFeedbackGenerator.rigid

**Android**:
- `light`: HapticFeedbackConstants.KEYBOARD_TAP
- `medium`: HapticFeedbackConstants.VIRTUAL_KEY
- `heavy`: HapticFeedbackConstants.LONG_PRESS
- `rigid`: HapticFeedbackConstants.REJECT

### Sound Effects

Define sound files in `spec/design.yaml`:

```yaml
feedback:
  sound:
    tap:
      file: "tap.wav"
      volume: 0.5
    reward:
      file: "reward.wav"
      volume: 0.8
```

## 🛠️ Adding New Components

To add a new UI component:

### 1. Define in Specification

Add entity definition to `spec/design.yaml`:

```yaml
entities:
  my_widget:
    type: interactive
    states:
      idle:
        visual:
          scale: 1.0
          glow: 0.1
      pressed:
        visual:
          scale: 0.95
          glow: 0.5
        feedback:
          haptic: light
```

### 2. Generate Code

```bash
python3 codegen/generator.py
```

### 3. Implement Renderer

Create renderer classes:
- iOS: `ios/renderer/MyWidgetRenderer.swift`
- Android: `android/renderer/MyWidgetRenderer.kt`

Use the generated config classes and extend base renderer.

## 🎮 Design Principles

### 1. State-Driven
All visual changes are driven by state transitions, not direct property manipulation.

### 2. Animation-First
Every state transition is animated. No instant jumps.

### 3. Feedback-Rich
Combine visual, haptic, and audio feedback for immersive interactions.

### 4. Platform-Native
Use platform-specific APIs for best performance:
- iOS: CALayer, Metal, CoreAnimation
- Android: Canvas, RuntimeShader, Choreographer

### 5. Single Source of Truth
The YAML specification is the only place where design decisions are made.

## 📊 Performance Characteristics

### iOS
- **Rendering**: CALayer (hardware-accelerated)
- **Glow**: Metal shaders (GPU)
- **Animations**: CoreAnimation (GPU)
- **60 FPS** smooth animations

### Android
- **Rendering**: Custom View + Canvas
- **Glow**: RuntimeShader (GPU, API 31+)
- **Animations**: Choreographer (frame-synced)
- **60 FPS** smooth animations

## 🧪 Testing

### Manual Testing

Test state transitions:

```swift
// iOS
let button = GameButton(frame: frame, title: "Test")
button.renderer.handleTouchDown()
button.renderer.triggerReward()
button.renderer.triggerError()
```

```kotlin
// Android
val button = ButtonRenderer(context, "Test")
button.triggerReward()
button.triggerError()
```

### Visual Testing

Use the provided example apps to visually test all states and transitions.

## 🔧 Configuration

### Timing Adjustments

Edit motion timings in `spec/design.yaml`:

```yaml
tokens:
  motion:
    fast: 120      # Quick interactions
    normal: 240    # Standard animations
    emphasis: 400  # Important transitions
    slow: 600      # Dramatic effects
```

### Color Theme

Customize the color palette:

```yaml
tokens:
  colors:
    primary: "#YOUR_COLOR"
    secondary: "#YOUR_COLOR"
    # ...
```

### Glow Intensity

Adjust glow for each state:

```yaml
entities:
  button:
    states:
      idle:
        visual:
          glow: 0.2  # 0.0 to 1.0
```

## 📚 API Reference

### iOS

#### EntityState (enum)
```swift
enum EntityState: String, CaseIterable {
    case idle, focus, pressed, active, rewarded, error, disabled
    
    func canTransition(to: EntityState) -> Bool
    func transition(to: EntityState) -> EntityState?
}
```

#### GameButton (class)
```swift
class GameButton: UIView {
    init(frame: CGRect, title: String)
    func onTap(_ handler: @escaping () -> Void)
    func showReward()
    func showError()
}
```

### Android

#### EntityState (sealed class)
```kotlin
sealed class EntityState(val stateName: String) {
    object Idle : EntityState("idle")
    // ...
    
    fun canTransitionTo(target: EntityState): Boolean
    fun transitionTo(target: EntityState): EntityState?
}
```

#### ButtonRenderer (class)
```kotlin
class ButtonRenderer(context: Context, title: String) : CanvasRenderer(context) {
    fun setOnClickListener(handler: () -> Unit)
    fun triggerReward()
    fun triggerError()
}
```

## 🤝 Contributing

1. Modify `spec/design.yaml` for design changes
2. Run `python3 codegen/generator.py` to regenerate code
3. Implement platform-specific renderers
4. Test on both iOS and Android
5. Update documentation

## 📝 License

This project is provided as-is for educational and commercial use.

## 🎯 Roadmap

- [ ] Complete Card renderer
- [ ] Complete Panel renderer
- [ ] Complete Energy Bar renderer
- [ ] Complete HUD Navigation renderer
- [ ] Sound engine integration
- [ ] Advanced particle effects
- [ ] Custom Metal/RuntimeShader implementations
- [ ] Performance profiling tools
- [ ] Visual design tool
- [ ] Storybook for components

## 💡 Philosophy

> "Make apps feel like games. Every tap should feel satisfying. Every transition should be smooth. Every interaction should provide feedback."

This design system treats mobile apps not as collections of buttons and forms, but as interactive experiences where every element is alive and responsive.

---

**Made with ❤️ for game-like mobile experiences**
