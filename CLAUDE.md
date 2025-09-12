# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application called "Peace" - a motivational quote app with customizable fonts and answer libraries. The app provides inspirational answers and allows users to save them as images to their photo gallery.

## Development Commands

### Build and Run
```bash
flutter run                    # Run in debug mode
flutter build ios --release    # Build iOS release
flutter build android --release # Build Android release
```

### Code Quality
```bash
flutter analyze                # Static analysis
flutter test                   # Run unit tests
flutter pub get                # Install dependencies
```

### Platform-specific Commands
```bash
# iOS debugging (VSCode launch configurations available)
# Check .vscode/launch.json for available debug configurations
```

## Architecture

### Core Structure
- **Main Entry**: `lib/main.dart` - App initialization and theming
- **Pages**: Main UI screens (answer display, history, settings, library)
- **Services**: Business logic layer with specialized services
- **Components**: Reusable UI widgets (dialogs, themes)
- **Data**: Static data definitions (answer libraries)

### Service Layer
The app follows a service-oriented architecture:

- **LoggerService** (`lib/services/logger_service.dart`): Centralized logging with categorization
- **AnswerLibraryService** (`lib/services/answer_library_service.dart`): Manages answer collections and user preferences
- **FontService** (`lib/services/font_service.dart`): Handles font selection and persistence

### Key Features
- **Answer Libraries**: Predefined collections of motivational quotes
- **Font Customization**: Google Fonts integration with user preferences
- **Image Saving**: Screenshot functionality with photo gallery integration
- **History Tracking**: User's previously viewed answers
- **Immersive UI**: Full-screen mode with custom theming

## Development Guidelines

### iOS Photo Permissions
Follow the strict guidelines in `.cursor/rules/photo-permission-rules.md`:
- Use `image_gallery_saver` plugin's built-in permission handling
- Request permissions only when user initiates save action
- Configure proper `Info.plist` descriptions for photo library access

### Code Quality Standards
From `.cursor/rules/flutter-deprecated-api.mdc`:
- Use `Colors.red.withValues(alpha: 0.5)` instead of `withOpacity()`
- Use `color.a` instead of `color.opacity`
- Run `flutter analyze` before commits

### Debug Features
Follow `.cursor/rules/debug-features.mdc`:
- Use `kDebugMode` for debug-only features
- Implement proper logging with LoggerService
- Add visual debug information when helpful

### Design Code Organization
Per `.cursor/rules/design-code-organization.mdc`:
- Place design/prototype files in `doc/` directory
- Optimize for iPhone 16 Pro screen (2556 × 1179 pixels)
- Use responsive design principles

## File Organization

```
lib/
├── main.dart                 # App entry point
├── services/                 # Business logic services
│   ├── logger_service.dart
│   ├── answer_library_service.dart
│   └── font_service.dart
├── pages/                    # Secondary pages
├── components/               # Reusable UI components
└── data/                     # Static data definitions
```

## Testing

- Unit tests in `test/widget_test.dart`
- Run with `flutter test`
- Ensure all tests pass before commits

## Platform Support

- **Primary**: iOS (with extensive permission handling)
- **Secondary**: Android, Web, Linux, Windows, macOS
- **Target Device**: iPhone 16 Pro optimization

## Important Notes

- App uses immersive full-screen mode (`SystemUiMode.immersiveSticky`)
- Extensive logging system for debugging and user behavior tracking
- Photo saving requires careful permission handling on iOS
- Font system uses Google Fonts with local preference storage
- All UI text and documentation in Chinese