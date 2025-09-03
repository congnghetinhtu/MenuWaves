# MenuWaves

<div align="center">
  <img src="https://img.shields.io/badge/Platform-macOS-blue.svg" alt="Platform">
  <img src="https://img.shields.io/badge/Architecture-Apple%20Silicon-green.svg" alt="Apple Silicon">
  <img src="https://img.shields.io/badge/Language-Swift-orange.svg" alt="Swift">
  <img src="https://img.shields.io/badge/Framework-SwiftUI%20%7C%20AppKit-red.svg" alt="Framework">
</div>

## 🌊 About

**MenuWaves** is a stunning animated menu bar application designed exclusively for Apple Silicon Macs. It brings beautiful wave animations, galaxy backgrounds, and dynamic visual effects directly to your macOS menu bar, creating an immersive and responsive user experience. And moreover, this is an app that have a countdown clock to the World 3 Event

## ✨ Features

### 🎨 Dynamic Wave Animation
- **Smooth wave rendering** with customizable amplitude and frequency
- **Motion blur effects** for professional-grade visual quality
- **Gradient colors** that change dynamically over time
- **Sparkle effects** and animated stars
- **30-second animation cycles** with seamless transitions

### 🔋 Battery Integration
- **Smart charging detection** - automatically responds when your Mac is plugged in
- **Green wave effect** that flows across the menu bar when charging begins
- **Real-time battery monitoring** with visual feedback

### 🌌 Galaxy Background
- **Twinkling stars** that move and breathe with the animation
- **Floating particles** with motion blur trails
- **Ripple effects** that appear randomly across the galaxy
- **Depth and atmosphere** for an immersive experience

### 📝 Interactive Text Display
- **"Thanh Solar NEXT"** with stunning gradient effects
- **Flip transitions** to countdown display
- **Live countdown** to January 1, 2050
- **Smooth scaling and bounce effects**

### ⚙️ Menu Bar Features
- **Customizable visibility** - option to hide from Dock
- **Right-click context menu** with quick actions
- **Quit option** with proper cleanup
- **200px dynamic width** for optimal display

## 🚀 Installation

### Requirements
- **macOS 12.0+** (Monterey or later)
- **Apple Silicon Mac** (M1, M2, M3 series)
- **Xcode 14.0+** for building from source

### Building from Source
1. Clone the repository:
```bash
git clone https://github.com/congnghetinhtu/MenuWaves.git
cd MenuWaves
```

2. Open the project in Xcode:
```bash
open menuWaves.xcodeproj
```

3. Select your development team and bundle identifier
4. Build and run the project (⌘+R)

### Installation
1. Build the app in Release mode
2. Copy `MenuWaves.app` to your `/Applications` folder
3. Launch the app - it will appear in your menu bar
4. Right-click the menu bar icon for options

## 🏗️ Architecture

### Core Components

**Managers**
- `MenuBarManager` - Handles menu bar integration and user interactions
- `BatteryMonitor` - Monitors charging state with real-time updates

**Controllers**
- `EffectController` - Orchestrates the entire animation pipeline

**Animators**
- `WaveAnimator` - Creates fluid wave animations with physics-based movement
- `AllyAnimator` - Manages text animations and countdown displays

**Renderers**
- `GalaxyRenderer` - Renders background galaxy with particles and effects

**Helpers**
- `DrawingHelpers` - Core Graphics utilities for rendering all visual elements

### Technical Implementation
- **60fps refresh rate** for buttery smooth animations
- **Delegation pattern** for clean component communication
- **Timer-based animation system** with proper lifecycle management
- **Motion blur rendering** using multiple drawing layers
- **Memory-efficient** with automatic cleanup and weak references

## 🎯 Performance

MenuWaves is optimized specifically for Apple Silicon, taking advantage of:
- **Metal Performance Shaders** for GPU-accelerated rendering
- **Unified memory architecture** for efficient graphics operations
- **Energy-efficient animation** with intelligent frame pacing
- **Minimal CPU impact** - designed to run continuously without affecting system performance

## 📖 Usage

### Basic Operation
Once installed, MenuWaves runs automatically in your menu bar. The animation cycle includes:

1. **Wave Phase** (30 seconds) - Continuous wave animation with galaxy background
2. **Transition Phase** (2 seconds) - Wave reverses as text appears
3. **Text Phase** (12 seconds) - "Thanh Solar NEXT" with gradient effects
4. **Countdown Phase** (countdown to 2050)
5. **Reset** - Cycle begins again

### Interactions
- **Right-click** the menu bar icon for options
- **"Hide from Dock"** - Toggle app visibility in Dock
- **"Quit"** - Cleanly exit the application

### Charging Effects
When you plug in your MacBook:
- A green wave effect automatically flows across the menu bar
- The effect lasts for 2 seconds and seamlessly integrates with existing animations
- No user interaction required - it's completely automatic

## 🛠️ Development

### Project Structure
```
menuWaves/
├── menuWavesApp.swift          # Main app entry point
├── ContentView.swift           # SwiftUI views
├── Managers/                   # Core system managers
│   ├── MenuBarManager.swift
│   └── BatteryMonitor.swift
├── Controllers/                # Animation controllers
│   └── EffectController.swift
├── Animators/                  # Animation engines
│   ├── WaveAnimator.swift
│   └── AllyAnimator.swift
├── Renderers/                  # Graphics renderers
│   └── GalaxyRenderer.swift
└── Helpers/                    # Utilities and extensions
    └── DrawingHelpers.swift
```

### Contributing
We welcome contributions! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on Apple Silicon
5. Submit a pull request

## 📄 License

Copyright © 2025 SOTech. All rights reserved.

## 👨‍💻 Credits

**Developer:** Thanh Solar  
**Company:** SOTech  
**Designed for:** Apple Silicon Macs

---

<div align="center">
  <strong>Experience the future of menu bar applications with MenuWaves</strong><br>
  <em>Crafted with ❤️ for Apple Silicon</em>
</div>
