# Quick Start Guide

## 🚀 Getting Started in 5 Minutes

### Prerequisites

- **iOS**: Xcode 14+, Swift 5.5+
- **Android**: Android Studio, Kotlin 1.8+
- **Code Generation**: Python 3.7+

### Step 1: Clone and Explore

```bash
git clone https://github.com/newro0209/designsystem0.git
cd designsystem0
```

Project structure:
```
designsystem0/
├── spec/design.yaml          # 👈 Edit this to customize
├── codegen/generator.py      # 👈 Run this to generate code
├── ios/                      # iOS implementation
├── android/                  # Android implementation
├── examples/                 # Working examples
└── docs/                     # Documentation
```

### Step 2: Generate Code (Optional)

The code is already generated, but you can regenerate it:

```bash
python3 codegen/generator.py
```

This creates:
- `ios/generated/` - Swift state machines and configs
- `android/generated/` - Kotlin state machines and configs

### Step 3A: Try iOS Example

1. **Create new iOS project** in Xcode
2. **Copy files** to your project:
   - `ios/generated/*.swift`
   - `ios/renderer/*.swift`
   - `examples/LobbyViewController.swift`

3. **Set as root view controller**:
```swift
// In SceneDelegate.swift or AppDelegate.swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, 
           options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = LobbyViewController()
    window.makeKeyAndVisible()
    self.window = window
}
```

4. **Run the app!** 🎉

### Step 3B: Try Android Example

1. **Create new Android project** in Android Studio (Empty Activity)

2. **Create package structure**:
```
app/src/main/java/com/yourapp/
├── designsystem/
│   ├── core/           # Copy android/generated/*.kt here
│   ├── entities/       # Copy android/generated/*Config.kt here
│   └── renderer/       # Copy android/renderer/*.kt here
└── examples/           # Copy examples/LobbyActivity.kt here
```

3. **Update AndroidManifest.xml**:
```xml
<activity
    android:name=".examples.LobbyActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LAUNCHER" />
    </intent-filter>
</activity>
```

4. **Run the app!** 🎉

### Step 4: Create Your First Button

#### iOS

```swift
import UIKit

class MyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.from(token: "background")
        
        // Create game-like button
        let button = GameButton(
            frame: CGRect(x: 100, y: 200, width: 200, height: 60),
            title: "PLAY"
        )
        
        button.onTap {
            print("Tapped!")
            button.showReward()  // Particle burst + animation
        }
        
        view.addSubview(button)
    }
}
```

#### Android

```kotlin
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.view.ViewGroup
import com.designsystem.renderer.ButtonRenderer

class MyActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Create game-like button
        val button = ButtonRenderer(this, "PLAY").apply {
            layoutParams = ViewGroup.LayoutParams(600, 200)
            setOnClickListener {
                println("Tapped!")
                triggerReward()  // Particle burst + animation
            }
        }
        
        setContentView(button)
    }
}
```

### Step 5: Customize the Design

Edit `spec/design.yaml`:

```yaml
# Change colors
tokens:
  colors:
    primary: "#YOUR_COLOR"  # Change button color
    
# Adjust animation speed
tokens:
  motion:
    fast: 100        # Make faster
    normal: 200      # Make faster
    
# Modify button behavior
entities:
  button:
    states:
      pressed:
        visual:
          scale: 0.85    # More dramatic press
          glow: 1.0      # Brighter glow
```

Then regenerate:
```bash
python3 codegen/generator.py
```

## 🎮 Try All Button States

### iOS

```swift
let button = GameButton(frame: frame, title: "Test")

// Focus state (highlight)
button.renderer.handleFocus()

// Press state
button.renderer.handleTouchDown()
button.renderer.handleTouchUp()

// Reward animation (success)
button.showReward()

// Error animation (shake)
button.showError()
```

### Android

```kotlin
val button = ButtonRenderer(context, "Test")

// Focus state (highlight)
button.handleFocus()

// Reward animation (success)
button.triggerReward()

// Error animation (shake)
button.triggerError()
```

## 📱 See It In Action

The example lobby screens demonstrate:

- ✨ **Enter animation** - Buttons fade in with scale
- 🎯 **Focus state** - Hover/highlight effect
- 👆 **Press state** - Scale down with glow
- 🎉 **Reward state** - Particle burst + scale up
- ❌ **Error state** - Shake + color change
- 📳 **Haptic feedback** - Feel the interactions

## 🎨 Available States

1. **idle** - Default resting state
2. **focus** - Highlighted (keyboard/pointer)
3. **pressed** - Being touched
4. **active** - Currently selected
5. **rewarded** - Success animation
6. **error** - Error/failure animation
7. **disabled** - Inactive

## 🔊 Features

### Visual Effects
- ✨ Glow (shadow-based on iOS, blur on Android)
- 🎆 Particles (CAEmitterLayer on iOS, Canvas on Android)
- 📐 Scale animations
- 🌈 Color transitions
- 💫 Shake effect
- 💓 Pulse effect

### Feedback
- 📳 Haptic feedback (4 intensities)
- 🔊 Sound support (configured in YAML)

### Performance
- 🚀 60 FPS animations
- ⚡ Hardware-accelerated rendering
- 🎯 Native platform APIs

## 🛠️ Next Steps

1. **Read the full README** - `README.md`
2. **Explore API docs** - `docs/API.md`
3. **Implementation guide** - `docs/IMPLEMENTATION.md`
4. **Customize design** - Edit `spec/design.yaml`
5. **Add more entities** - Follow patterns in existing renderers

## 💡 Tips

- Start with the Button - it's fully implemented
- Copy the renderer pattern for new entities
- Use the code generator - don't duplicate code
- Test on real devices for haptic feedback
- Profile with Instruments/Android Profiler

## 🐛 Troubleshooting

### Animations not smooth
- iOS: Check that layer has proper bounds
- Android: Enable hardware acceleration

### Glow not visible
- iOS: Set `masksToBounds = false` on layer
- Android: Use software layer type

### Haptic not working
- Test on physical device (simulators limited)
- Check haptic permissions/settings

## 📚 Learn More

- **Architecture**: See README.md "Architecture" section
- **Add entities**: See docs/IMPLEMENTATION.md "How to Extend"
- **API reference**: See docs/API.md
- **YAML spec**: Read spec/design.yaml with comments

## 🎯 What You Get

✅ **Single source of truth** - YAML drives everything  
✅ **Native performance** - No cross-platform overhead  
✅ **Game-like UX** - Smooth, responsive, satisfying  
✅ **Type-safe** - Generated code with proper types  
✅ **Maintainable** - Add entities by editing YAML  
✅ **Consistent** - Identical behavior on iOS & Android  

---

**Ready to make your apps feel like games?** Start coding! 🚀
