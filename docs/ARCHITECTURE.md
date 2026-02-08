# Architecture Overview

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     spec/design.yaml                        │
│                  (Single Source of Truth)                   │
│                                                             │
│  ┌─────────────┐  ┌──────────┐  ┌─────────┐  ┌──────────┐ │
│  │   Tokens    │  │ Entities │  │ Motions │  │ Feedback │ │
│  │ ─────────── │  │──────────│  │─────────│  │──────────│ │
│  │ • Colors    │  │ • Button │  │ • Enter │  │ • Haptic │ │
│  │ • Motion    │  │ • Card   │  │ • Focus │  │ • Sound  │ │
│  │ • Elevation │  │ • Panel  │  │ • Open  │  │          │ │
│  │ • Spacing   │  │ • Energy │  │ • Reward│  │          │ │
│  │ • Typography│  │ • HUD    │  │ • Shake │  │          │ │
│  └─────────────┘  └──────────┘  └─────────┘  └──────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ python3 codegen/generator.py
                              ▼
                    ┌─────────────────┐
                    │  Code Generator  │
                    │  (Python)        │
                    └─────────────────┘
                              │
              ┌───────────────┴───────────────┐
              │                               │
              ▼                               ▼
┌──────────────────────────┐    ┌──────────────────────────┐
│    iOS Generated Code    │    │  Android Generated Code  │
│    (Swift)               │    │  (Kotlin)                │
│                          │    │                          │
│  • EntityState.swift     │    │  • EntityState.kt        │
│  • ButtonConfig.swift    │    │  • ButtonConfig.kt       │
│  • CardConfig.swift      │    │  • CardConfig.kt         │
│  • PanelConfig.swift     │    │  • PanelConfig.kt        │
│  • EnergyBarConfig.swift │    │  • EnergyBarConfig.kt    │
│  • HUDNavigationConfig   │    │  • HUDNavigationConfig   │
└──────────────────────────┘    └──────────────────────────┘
              │                               │
              │                               │
              ▼                               ▼
┌──────────────────────────┐    ┌──────────────────────────┐
│   iOS Renderer Layer     │    │  Android Renderer Layer  │
│   (Hand-written)         │    │  (Hand-written)          │
│                          │    │                          │
│  • BaseRenderer.swift    │    │  • BaseRenderer.kt       │
│    - CALayer             │    │    - Custom View         │
│    - CoreAnimation       │    │    - Canvas              │
│    - Metal (glow)        │    │    - RuntimeShader       │
│    - Particles           │    │    - Choreographer       │
│                          │    │    - Particles           │
│  • ButtonRenderer.swift  │    │  • ButtonRenderer.kt     │
│  • CardRenderer.swift    │    │  • CardRenderer.kt       │
│  • ...                   │    │  • ...                   │
└──────────────────────────┘    └──────────────────────────┘
              │                               │
              │                               │
              ▼                               ▼
┌──────────────────────────┐    ┌──────────────────────────┐
│    UIKit/SwiftUI App     │    │     Compose/Views App    │
│    (Layout only)         │    │     (Layout only)        │
│                          │    │                          │
│  • LobbyViewController   │    │  • LobbyActivity         │
│  • Uses GameButton       │    │  • Uses ButtonRenderer   │
│  • Layout in UIKit       │    │  • Layout in Compose     │
└──────────────────────────┘    └──────────────────────────┘
```

## 🔄 State Machine Flow

```
              ┌──────────────────────────────┐
              │     Universal States         │
              │                              │
              │  ┌────────────────────────┐  │
              │  │         IDLE           │◄─┼──── Default
              │  └───┬────────────────┬───┘  │
              │      │                │      │
              │   Focus           Press      │
              │      │                │      │
              │      ▼                ▼      │
              │  ┌────────┐      ┌────────┐ │
        ┌─────┼─►│ FOCUS  │      │PRESSED │◄┼─────┐
        │     │  └────┬───┘      └───┬────┘ │     │
        │     │       │              │      │     │
    Keyboard │       └──────┬───────┘      │  Touch
      /Mouse │              │              │  Events
        │     │              ▼              │     │
        │     │         ┌────────┐         │     │
        └─────┼─────────│ ACTIVE │─────────┼─────┘
              │         └────┬───┘         │
              │              │             │
              │         Success/Error      │
              │              │             │
              │      ┌───────┴───────┐    │
              │      ▼               ▼    │
              │  ┌────────┐      ┌────────┐
              │  │REWARDED│      │ ERROR  │
              │  │(burst) │      │(shake) │
              │  └───┬────┘      └───┬────┘
              │      │               │    │
              │      └───────┬───────┘    │
              │              │            │
              │              ▼            │
              │         ┌────────┐       │
              │         │DISABLED│       │
              │         └────────┘       │
              └──────────────────────────┘
```

## 🎨 Rendering Pipeline

### iOS (CALayer + Metal)

```
┌──────────────┐
│ GameButton   │  UIView Wrapper
└──────┬───────┘
       │
       ▼
┌──────────────────┐
│ ButtonRenderer   │  Implements EntityRenderer
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│ CALayerRenderer  │  Base Renderer
│                  │
│ • rootLayer      │  Main layer
│ • glowLayer      │  Shadow-based glow
│ • contentLayer   │  Button shape
│ • labelLayer     │  Text
│ • particleLayer  │  CAEmitterLayer
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│ CALayer Tree     │  Hardware-accelerated
│                  │
│ • GPU rendering  │
│ • Compositing    │
│ • CoreAnimation  │
└──────────────────┘
```

### Android (Canvas + Choreographer)

```
┌──────────────┐
│ButtonRenderer│  Custom View
└──────┬───────┘
       │
       ▼
┌──────────────────┐
│ CanvasRenderer   │  Base Renderer
│                  │
│ • Canvas         │  Drawing surface
│ • Paint          │  Styling
│ • Path           │  Shapes
│ • Particles[]    │  Particle system
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│ onDraw(canvas)   │  Draw cycle
│                  │
│ 1. Background    │
│ 2. Glow (blur)   │
│ 3. Content       │
│ 4. Text          │
│ 5. Particles     │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│ Choreographer    │  Frame sync
│                  │
│ • 60 FPS         │
│ • GPU rendering  │
│ • HW acceleration│
└──────────────────┘
```

## 📊 Data Flow

### Design Change Flow

```
1. Edit YAML
   spec/design.yaml
   └─ Change button color

2. Run Generator
   python3 codegen/generator.py
   └─ Regenerate configs

3. Build App
   iOS / Android
   └─ New color applied automatically
```

### State Transition Flow

```
User Touch
    │
    ▼
┌─────────────┐
│Handle Touch │
└──────┬──────┘
       │
       ▼
┌──────────────────┐
│Check Transition  │  currentState.canTransitionTo(newState)
└──────┬───────────┘
       │
   Valid? ─Yes→ ┌─────────────────┐
       │        │ Animate          │
       No       │ from → to        │
       │        └──────┬───────────┘
       │               │
       ▼               ▼
  Ignore        ┌─────────────┐
                │ Update State│
                └──────┬──────┘
                       │
                       ▼
                ┌──────────────┐
                │ Apply Visual │
                │ • Scale      │
                │ • Glow       │
                │ • Color      │
                │ • Effects    │
                └──────┬───────┘
                       │
                       ▼
                ┌──────────────┐
                │ Haptic       │
                └──────────────┘
```

## 🎯 Component Architecture

### Button Component Layers

```
┌─────────────────────────────────────┐
│         UIView / View               │  Layout container
│         (UIKit/Compose)             │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│         ButtonRenderer              │  Business logic
│                                     │
│  • State machine                    │
│  • Event handling                   │
│  • Animation control                │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│         BaseRenderer                │  Visual effects
│                                     │
│  • Drawing                          │
│  • Glow effects                     │
│  • Particles                        │
│  • Animations                       │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│         ButtonConfig                │  Configuration
│         (Auto-generated)            │
│                                     │
│  • State visuals                    │
│  • Animation timings                │
│  • Feedback settings                │
└─────────────────────────────────────┘
```

## 🔌 Platform Integration

### iOS App Integration

```swift
// 1. Import generated code + renderers
import YourApp

// 2. Create button
let button = GameButton(
    frame: CGRect(x: 100, y: 200, width: 200, height: 60),
    title: "PLAY"
)

// 3. Add to view hierarchy
view.addSubview(button)

// 4. Handle interactions
button.onTap {
    // Your logic
    button.showReward()
}
```

### Android App Integration

```kotlin
// 1. Import generated code + renderers
import com.designsystem.renderer.ButtonRenderer

// 2. Create button
val button = ButtonRenderer(context, "PLAY").apply {
    layoutParams = ViewGroup.LayoutParams(600, 200)
}

// 3. Add to view hierarchy
layout.addView(button)

// 4. Handle interactions
button.setOnClickListener {
    // Your logic
    button.triggerReward()
}
```

## 🎬 Animation System

### Animation Timing (from spec)

```
Fast (120ms)
├─ Focus transition
├─ Pressed transition
└─ Quick feedback

Normal (240ms)
├─ Standard transitions
├─ Idle ↔ State changes
└─ Most animations

Emphasis (400ms)
├─ Important changes
├─ Reward animations
└─ Panel opening

Slow (600ms)
├─ Dramatic effects
└─ Complex motions
```

### Animation Curves

```
easeIn      ───────╱
            ______/

easeOut     ╲
             ╲_______

easeInOut   ╱────╲
           /      \_____

spring      ╱╲╱╲╲
           /    ╲____

linear      ────────────
```

## 🔊 Feedback System

```
┌──────────────┐
│ User Action  │
└──────┬───────┘
       │
       ├──────────────┐
       │              │
       ▼              ▼
┌──────────┐   ┌──────────┐
│  Visual  │   │  Haptic  │
│          │   │          │
│ • Scale  │   │ • Light  │
│ • Glow   │   │ • Medium │
│ • Color  │   │ • Heavy  │
│ • Shake  │   │ • Rigid  │
│ • Burst  │   │          │
└──────────┘   └──────────┘
       │              │
       │              │
       │       ┌──────────┐
       │       │  Sound   │
       │       │          │
       │       │ • Tap    │
       │       │ • Reward │
       └───────┤ • Error  │
               │          │
               └──────────┘
```

## 📦 File Organization

```
designsystem0/
│
├── spec/                      # Source of truth
│   └── design.yaml            # All design decisions
│
├── codegen/                   # Automation
│   └── generator.py           # Generates platform code
│
├── ios/                       # iOS platform
│   ├── generated/             # Auto-generated (don't edit)
│   │   ├── EntityState.swift
│   │   └── *Config.swift
│   └── renderer/              # Hand-written
│       ├── BaseRenderer.swift
│       └── *Renderer.swift
│
├── android/                   # Android platform
│   ├── generated/             # Auto-generated (don't edit)
│   │   ├── EntityState.kt
│   │   └── *Config.kt
│   └── renderer/              # Hand-written
│       ├── BaseRenderer.kt
│       └── *Renderer.kt
│
├── examples/                  # Usage examples
│   ├── LobbyViewController.swift
│   └── LobbyActivity.kt
│
└── docs/                      # Documentation
    ├── QUICKSTART.md
    ├── API.md
    ├── IMPLEMENTATION.md
    └── ARCHITECTURE.md (this file)
```

## 🎯 Key Design Decisions

### 1. Single Source of Truth
- **Why**: Prevent drift between platforms
- **How**: YAML spec → Code generation

### 2. State Machine
- **Why**: Predictable, testable behavior
- **How**: Explicit states and transitions

### 3. Platform Native
- **Why**: Best performance, no compromise
- **How**: Direct CALayer/Canvas APIs

### 4. Code Generation
- **Why**: DRY, consistency, less errors
- **How**: Python script reads YAML

### 5. Separation of Concerns
- **Config**: Auto-generated from YAML
- **Renderer**: Platform-specific drawing
- **Wrapper**: Integration with UI framework

## 🚀 Performance Profile

### iOS
- Rendering: GPU (CALayer)
- Animation: Separate thread
- Particles: Metal shaders
- Target: 60 FPS

### Android
- Rendering: GPU (hardware accel)
- Animation: Choreographer (vsync)
- Particles: Canvas + GPU
- Target: 60 FPS

## 🎨 Visual Effect Stack

```
Layer 5: Particles     ✨ (burst effects)
Layer 4: Glow          🌟 (shadow/blur)
Layer 3: Content       ▪️  (shape)
Layer 2: Text          📝 (label)
Layer 1: Background    ⬜ (optional)
```

---

This architecture enables:
- ✅ Cross-platform consistency
- ✅ Native performance
- ✅ Easy maintenance
- ✅ Rapid iteration
- ✅ Type safety
- ✅ Testability
