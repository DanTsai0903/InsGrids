# Project Context

## Purpose

**InsGrids** is an iOS photo editing application designed to add customizable borders to photos, making them perfect for social media platforms like Instagram. The app helps users:

- Create photos with specific aspect ratios (1:1, 4:5, 16:9, 9:16)
- Add customizable colored borders (white, black, or custom colors)
- Batch process multiple photos efficiently
- Save and apply preset configurations for quick editing

The app prioritizes **memory efficiency**, **user privacy**, and **localization** to provide a smooth experience even when processing high-resolution images.

## Tech Stack

### Core Technologies
- **Swift 5.9+** - Primary programming language
- **SwiftUI** - Declarative UI framework for all views
- **iOS 26.0+** - Minimum deployment target
- **Xcode 26.2+** - Development environment

### iOS Frameworks
- **PhotosUI** - Modern photo picker with minimal permissions (`.addOnly`)
- **UIKit** - Image processing and rendering (`UIGraphicsImageRenderer`)
- **Combine** - Reactive programming for view models
- **UserDefaults** - Persistent storage for presets and configurations

### Build Tools
- **XcodeGen** - Project file generation from `project.yml`
- **AltStore** - Alternative deployment method (no Apple Developer account required)

## Project Conventions

### Code Style

- **Language**: Swift with strict type safety
- **Naming Conventions**:
  - `PascalCase` for types (classes, structs, enums)
  - `camelCase` for properties, methods, and variables
  - Descriptive names that clearly indicate purpose
- **SwiftUI Patterns**:
  - Use `@Published` for observable properties
  - Prefer `@StateObject` for view model ownership
  - Use `@ObservedObject` for passed view models
- **Async/Concurrency**:
  - Use `DispatchQueue` for background processing
  - Wrap image processing in `autoreleasepool` blocks to manage memory
  - Serial processing for high-resolution images (one at a time)

### Architecture Patterns

**MVVM (Model-View-ViewModel)**

```
Models/
  ├── BorderConfiguration.swift    # Data model with Codable for persistence
  ├── ImageProcessor.swift         # Singleton for image processing logic
  └── Preset.swift                 # User-saved configuration presets

ViewModels/
  ├── PhotoEditorViewModel.swift   # Main editing logic and state
  └── PresetManager.swift          # Preset CRUD operations

Views/
  ├── ContentView.swift            # Root view
  ├── EditingView.swift            # Main editing interface
  └── Components/                  # Reusable UI components
```

**Key Patterns**:
- **Singleton Pattern**: `ImageProcessor.shared` and `ImageExporter.shared`
- **Separation of Concerns**: Views handle UI, ViewModels handle logic, Models handle data
- **Memory Management**: Thumbnail-based previews + serial full-resolution processing
- **Custom Codable**: Custom encoding/decoding for `SwiftUI.Color` using `UIColor` + `NSKeyedArchiver`

### Testing Strategy

**Current Status**: No automated tests currently implemented

**Preferred Testing Stack** (from user rules): `pytest` (for Python projects)

**Future iOS Testing Approach** (when implemented):
- **XCTest** for unit tests
- **XCUITest** for UI tests
- Focus on:
  - Image processing accuracy
  - Memory management under load
  - Preset save/load functionality
  - Localization string coverage

### Git Workflow

- **Project File Generation**: `.xcodeproj` is gitignored; use `xcodegen generate` to regenerate
- **Source of Truth**: `project.yml` for project configuration
- **Build Artifacts**: `.ipa` files are gitignored; use `./generate_ipa.sh` to rebuild
- **Standard Git Practices**:
  - Meaningful commit messages
  - Feature branches for new functionality
  - Main branch for stable releases

## Domain Context

### Image Processing Domain

- **Aspect Ratios**: Common social media formats
  - `1:1` - Instagram square posts
  - `4:5` - Instagram portrait posts (most engagement)
  - `16:9` - Landscape/YouTube format
  - `9:16` - Instagram Stories/TikTok format

- **Memory Constraints**:
  - iOS devices have limited memory for image processing
  - High-resolution photos (e.g., 48MP iPhone photos) can cause crashes
  - Solution: Thumbnail previews (200px) + 12MP output limit + serial processing

- **Color Persistence Challenge**:
  - `SwiftUI.Color` is not directly `Codable`
  - Solution: Convert to `UIColor` → `NSKeyedArchiver` → `Data` for storage

### Localization

- **Supported Languages**:
  - English (`en`)
  - Traditional Chinese (`zh-Hant`)
- **Implementation**: `.lproj` folders with `Localizable.strings` and `InfoPlist.strings`
- **User Preference**: App follows system language settings

## Important Constraints

### Technical Constraints

1. **Memory Management**:
   - Must use `autoreleasepool` for batch processing
   - Limit output images to 12MP maximum
   - Process images serially (one at a time) not in parallel
   - Use 200px thumbnails for real-time preview

2. **iOS Requirements**:
   - Minimum iOS 26.0 (latest version focus)
   - Portrait orientation only (no landscape support)
   - PhotosPicker with `.addOnly` permission (privacy-focused)

3. **Build System**:
   - XcodeGen must be installed and run before opening project
   - `project.yml` is the single source of truth for build configuration
   - No manual `.xcodeproj` modifications (will be overwritten)

### Business/User Constraints

1. **Privacy First**:
   - Minimal photo library permissions
   - No analytics or tracking
   - No cloud storage or external uploads

2. **Free Distribution**:
   - Support for AltStore installation (no $99/year developer account)
   - 7-day app signing renewal via AltStore
   - Must remain free and accessible

3. **User Experience**:
   - Real-time preview must feel instant (use thumbnails)
   - Batch processing must show progress
   - No crashes even with large photo libraries

## External Dependencies

### None (First-Party Only)

InsGrids intentionally **avoids third-party dependencies** to maintain:
- **Security**: No external code execution
- **Privacy**: No data leaving the device
- **Stability**: No breaking changes from dependency updates
- **App Size**: Minimal binary size

All functionality is implemented using:
- Apple's first-party iOS frameworks
- Standard Swift library
- Custom implementations for color persistence, image processing, etc.
