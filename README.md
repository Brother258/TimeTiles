# TimeTiles 📅

**Beautiful Year Progress Live Wallpaper for Android**

<p align="center">
  <img src="https://img.shields.io/badge/Version-2.0.0-blue" alt="Version">
  <img src="https://img.shields.io/badge/Platform-Android-green" alt="Platform">
  <img src="https://img.shields.io/badge/Flutter-3.0+-blue" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.0+-blue" alt="Dart">
</p>

## Overview

TimeTiles is a customizable live wallpaper app that displays your year's progress as a beautiful grid of tiles. Watch each day pass as tiles fill up, providing a visual representation of time throughout the year.

## ✨ Features

### 📊 Year Progress Visualization
- Visual grid showing each day of the year as a tile
- Distinct colors for **past days**, **current day**, and **remaining days**
- Real-time progress tracking with percentage display

### 🎨 Extensive Customization

#### Color Options
- **Past Days Color** - Customize the color of days that have passed
- **Current Day Color** - Highlight today with a distinctive color
- **Empty Days Color** - Style the remaining days of the year

#### Background Styles
- **Solid Color** - Simple, clean backgrounds
- **Linear Gradient** - Smooth color transitions with adjustable angle
- **Radial Gradient** - Circular gradient effects
- **Sweep Gradient** - Angular sweep gradients
- **Custom Image** - Use your own images as wallpaper backgrounds

#### Layout Controls
- **Column Count** - Adjust the number of columns in the grid
- **Top Margin** - Control spacing from the top of the screen
- **Bottom Margin** - Control spacing from the bottom of the screen

#### Inspirational Quotes
- Add custom motivational quotes to your wallpaper
- Quotes are beautifully displayed below the year grid

### 📱 Live Wallpaper
- Set as your device's live wallpaper
- Settings persist and update in real-time
- Native Android live wallpaper integration

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   └── background_settings.dart       # Background configuration model
├── painters/
│   └── year_grid_painter.dart         # Custom painter for year grid
├── screens/
│   └── home_screen.dart               # Main settings screen
├── services/
│   └── wallpaper_channel_service.dart # Native platform communication
├── utils/
│   ├── color_utils.dart               # Color conversion utilities
│   └── year_utils.dart                # Date/year calculations
└── widgets/
    ├── background_editor.dart         # Background customization widget
    ├── color_picker_tile.dart         # Color selection widget
    ├── column_count_editor.dart       # Grid column editor
    ├── donation_section.dart          # Support/donation widget
    ├── margin_editor.dart             # Margin adjustment widget
    ├── quote_editor.dart              # Quote input widget
    └── year_grid_preview.dart         # Live wallpaper preview
```

## 🛠️ Tech Stack

- **Framework:** Flutter 3.0+
- **Language:** Dart 3.0+
- **Platform Channels:** Native Android communication
- **State Management:** StatefulWidget
- **Custom Painting:** Flutter Canvas API

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_colorpicker` | ^1.0.3 | Color selection UI |
| `url_launcher` | ^6.2.1 | Opening external links |
| `image_picker` | ^1.0.7 | Selecting background images |
| `path_provider` | ^2.1.2 | File system access |
| `cupertino_icons` | ^1.0.6 | iOS-style icons |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Brother258/TimeTiles.git
   cd TimeTiles
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Release

```bash
flutter build apk --release
```

The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`

## 📱 Usage

1. **Launch the App** - Open TimeTiles on your Android device
2. **Customize Colors** - Tap on color tiles to change past, current, and empty day colors
3. **Set Background** - Choose from solid colors, gradients, or custom images
4. **Add a Quote** - Enter an inspirational quote to display on your wallpaper
5. **Adjust Layout** - Modify column count and margins to your preference
6. **Save Settings** - Tap save to apply your changes
7. **Set as Wallpaper** - Use the wallpaper chooser to set as your live wallpaper

## 🎨 Background Types

| Type | Description |
|------|-------------|
| Solid Color | Single color background |
| Linear Gradient | Two-color gradient with adjustable angle |
| Radial Gradient | Circular gradient from center |
| Sweep Gradient | Angular sweep around center |
| Image | Custom image from device gallery |

## 📐 Year Utilities

The app includes utilities for accurate year calculations:

- **Leap Year Detection** - Correctly handles 365 vs 366 day years
- **Day of Year** - Calculates current day number (1-365/366)
- **Progress Calculation** - Percentage of year completed
- **Remaining Days** - Days left in the current year

## 🔧 Platform Channels

TimeTiles uses Flutter's platform channels to communicate with native Android code for:

- Saving and loading wallpaper preferences
- Opening the system wallpaper chooser
- Refreshing the live wallpaper display
- Managing background images

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📧 Contact

For questions, suggestions, or feedback, please open an issue on GitHub.

---

<p align="center">
  Made with ❤️ by Shahriar
</p>
