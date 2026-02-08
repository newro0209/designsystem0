# Implementation Guide

## Step-by-Step Implementation

### Phase 1: Setup (Completed ✅)

1. **Project Structure**
   - Created directory structure for spec, iOS, Android, codegen, examples, and docs
   - Organized files by platform and purpose

2. **YAML Specification**
   - Defined tokens (colors, spacing, motion, typography, elevation)
   - Created entity definitions (button, card, panel, energy_bar, hud_navigation)
   - Specified state machine (7 states with transitions)
   - Defined motion library (5 predefined animations)
   - Configured feedback system (haptic and sound)

3. **Code Generator**
   - Built Python-based code generator
   - Generates Swift state machines and entity configs
   - Generates Kotlin state machines and entity configs
   - Reads from single YAML source

### Phase 2: iOS Implementation (Completed ✅)

1. **Base Renderer**
   - `CALayerRenderer`: Base class for all renderers
   - Glow effects using shadow
   - Scale, opacity, elevation support
   - Particle system using CAEmitterLayer
   - Shake and pulse animations
   - Color utilities

2. **Button Renderer**
   - `ButtonRenderer`: Implements EntityRenderer protocol
   - Uses CAShapeLayer for button background
   - CATextLayer for text
   - Full state machine integration
   - Haptic feedback using UIImpactFeedbackGenerator
   - `GameButton`: UIView wrapper for easy integration

### Phase 3: Android Implementation (Completed ✅)

1. **Base Renderer**
   - `CanvasRenderer`: Base class for Canvas-based rendering
   - Glow effects using BlurMaskFilter
   - Elevation shadows
   - Particle system using Choreographer
   - Shake and pulse animations
   - Color utilities

2. **Button Renderer**
   - `ButtonRenderer`: Implements EntityRenderer interface
   - Custom View with Canvas drawing
   - Full state machine integration
   - Haptic feedback using HapticFeedbackConstants
   - Touch event handling

### Phase 4: Examples & Documentation (Completed ✅)

1. **iOS Example**
   - `LobbyViewController.swift`: Complete lobby screen example
   - Multiple buttons with different interactions
   - Entrance animations
   - Reward and error handling

2. **Android Example**
   - `LobbyActivity.kt`: Complete lobby screen example
   - Multiple buttons with different interactions
   - Entrance animations
   - Reward and error handling

3. **Documentation**
   - Comprehensive README with quick start
   - API reference
   - Architecture overview
   - Usage examples

## What's Implemented

### ✅ Complete

1. **YAML Specification**
   - All tokens defined
   - 5 core entities specified
   - State machine with 7 states
   - 5 motion definitions
   - Haptic and sound feedback specs

2. **Code Generation**
   - State machine generation for Swift and Kotlin
   - Entity config generation for Swift and Kotlin
   - Automatic generation from YAML

3. **iOS Renderer**
   - Base renderer with CALayer
   - Button entity fully implemented
   - Glow, particles, animations
   - Haptic feedback

4. **Android Renderer**
   - Base renderer with Canvas
   - Button entity fully implemented
   - Glow, particles, animations
   - Haptic feedback

5. **Examples**
   - iOS lobby screen
   - Android lobby activity
   - Both demonstrate all button states

6. **Documentation**
   - README with quick start
   - Implementation guide
   - API reference

### 🚧 Pending (Future Enhancements)

The following entities are specified in YAML and have generated config files, but need renderer implementations:

1. **Card Renderer**
   - iOS: Create `CardRenderer.swift`
   - Android: Create `CardRenderer.kt`
   - Implement elevation animations
   - Focus effects

2. **Panel Renderer**
   - iOS: Create `PanelRenderer.swift`
   - Android: Create `PanelRenderer.kt`
   - Background blur
   - Slide-up animation

3. **Energy Bar Renderer**
   - iOS: Create `EnergyBarRenderer.swift`
   - Android: Create `EnergyBarRenderer.kt`
   - Animated fill
   - Pulse effect

4. **HUD Navigation Renderer**
   - iOS: Create `HUDNavigationRenderer.swift`
   - Android: Create `HUDNavigationRenderer.kt`
   - Always-on-top positioning
   - Background blur

5. **Sound Engine**
   - iOS: AVAudioEngine integration
   - Android: SoundPool integration
   - Automatic sound playback from spec

6. **Metal Shaders (iOS)**
   - Custom Metal shader for glow
   - Particle system with Metal

7. **RuntimeShader (Android)**
   - Custom RuntimeShader for glow (API 31+)
   - Advanced visual effects

## How to Extend

### Adding a New Entity

1. **Define in YAML** (`spec/design.yaml`):
```yaml
entities:
  my_new_widget:
    type: interactive
    states:
      idle:
        visual:
          scale: 1.0
          glow: 0.2
      pressed:
        visual:
          scale: 0.95
          glow: 0.6
        feedback:
          haptic: medium
```

2. **Generate Code**:
```bash
python3 codegen/generator.py
```

This creates:
- `ios/generated/MyNewWidgetConfig.swift`
- `android/generated/MyNewWidgetConfig.kt`

3. **Implement iOS Renderer** (`ios/renderer/MyNewWidgetRenderer.swift`):
```swift
class MyNewWidgetRenderer: CALayerRenderer, EntityRenderer {
    typealias ConfigType = MyNewWidgetConfig
    
    var layer: CALayer { rootLayer }
    var currentState: EntityState = .idle
    let config: MyNewWidgetConfig
    
    // Implement rendering logic...
}
```

4. **Implement Android Renderer** (`android/renderer/MyNewWidgetRenderer.kt`):
```kotlin
class MyNewWidgetRenderer(context: Context) : 
    CanvasRenderer(context), EntityRenderer<MyNewWidgetConfig> {
    
    override var currentState: EntityState = EntityState.Idle
    override val config: MyNewWidgetConfig = MyNewWidgetConfig()
    
    // Implement rendering logic...
}
```

### Adding a New Motion

1. **Define in YAML**:
```yaml
motions:
  MyCustomMotion:
    description: "Custom animation"
    duration: "motion.emphasis"
    curve: "spring"
    effects:
      - type: "scale"
        from: 1.0
        to: 1.2
      - type: "rotation"
        from: 0
        to: 180
```

2. **Implement in Renderers**:
   - iOS: Add method to apply the motion
   - Android: Add method to apply the motion

### Modifying Design Tokens

Simply edit `spec/design.yaml` and regenerate:

```yaml
tokens:
  colors:
    primary: "#YOUR_NEW_COLOR"
  motion:
    fast: 100  # Speed up animations
```

Then run:
```bash
python3 codegen/generator.py
```

The generated configs will automatically use new values.

## Architecture Decisions

### Why YAML?
- Human-readable
- Easy to version control
- Single source of truth
- No code duplication

### Why CALayer (iOS)?
- Hardware-accelerated
- Smooth animations
- Efficient rendering
- Native to iOS

### Why Canvas (Android)?
- Full control over rendering
- Consistent with game engines
- Hardware-accelerated
- Native to Android

### Why State Machine?
- Predictable behavior
- Easy to reason about
- Prevents invalid states
- Consistent across platforms

### Why Code Generation?
- Eliminates duplication
- Reduces errors
- Ensures consistency
- Easy to maintain

## Performance Tips

### iOS
1. Use CALayer for simple shapes
2. Use Metal for complex effects
3. Reuse layers when possible
4. Enable layer caching for static content

### Android
1. Use Canvas for custom drawing
2. Enable hardware acceleration
3. Use RuntimeShader for GPU effects (API 31+)
4. Batch particle updates

### Both Platforms
1. Keep animation durations reasonable (120-400ms)
2. Limit particle count (20-50)
3. Use appropriate haptic intensities
4. Profile with performance tools

## Testing Strategy

### Unit Tests
- Test state transitions
- Verify config generation
- Validate YAML parsing

### Integration Tests
- Test renderer behavior
- Verify animations complete
- Check haptic feedback triggers

### Visual Tests
- Use example apps
- Test all states manually
- Verify animations are smooth
- Check on different screen sizes

### Performance Tests
- Measure frame rates
- Profile memory usage
- Test with many entities on screen

## Troubleshooting

### Code Generator Issues
**Problem**: Generator fails
**Solution**: Check YAML syntax, ensure all required fields present

### Animation Not Smooth (iOS)
**Problem**: Choppy animations
**Solution**: Use CoreAnimation, enable layer caching

### Animation Not Smooth (Android)
**Problem**: Choppy animations  
**Solution**: Enable hardware acceleration, use Choreographer

### Glow Not Visible
**Problem**: Glow effect not showing
**Solution**: Check masksToBounds is false, increase glow intensity

### Haptic Not Working
**Problem**: No haptic feedback
**Solution**: Check device capabilities, test on physical device

## Next Steps

To continue development:

1. Implement remaining entity renderers (Card, Panel, Energy Bar, HUD)
2. Add sound engine integration
3. Create advanced Metal/RuntimeShader effects
4. Build visual design tool
5. Add automated tests
6. Create component storybook
7. Optimize performance
8. Add more motion definitions
9. Create theme system
10. Build design token editor

## Resources

### iOS Development
- [CALayer Documentation](https://developer.apple.com/documentation/quartzcore/calayer)
- [Core Animation Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/)
- [Metal Programming Guide](https://developer.apple.com/metal/)

### Android Development
- [Custom View Guide](https://developer.android.com/develop/ui/views/layout/custom-views)
- [Canvas API](https://developer.android.com/reference/android/graphics/Canvas)
- [Choreographer](https://developer.android.com/reference/android/view/Choreographer)

### Design Systems
- [Material Design](https://material.io/)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Game UI Design Principles](https://www.gamedeveloper.com/design/)
