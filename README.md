# MediaPicker

[![Tests](https://github.com/Brenovisk/MediaPicker/actions/workflows/tests.yml/badge.svg?branch=develop)](https://github.com/Brenovisk/MediaPicker/actions/workflows/tests.yml?query=branch%3Adevelop)

MediaPicker is a SwiftUI-first package for capturing photos and videos with the
camera or selecting them from the photo library through one consistent API.

> [!IMPORTANT]
> MediaPicker is in early development. Camera photo capture and single-photo
> selection from the library are available on iOS; video recording and the
> unified picker API are not yet implemented. Public API and behavior may change
> before `1.0.0`. Follow the
> [v0.0.1 roadmap](Docs/Roadmapv0.0.1.md) for progress.

## Goals for v0.0.1

- Capture photos using the front or back camera.
- Record video with audio.
- Select a single photo or video from the system photo library.
- Return camera and library content through one result model.
- Provide a SwiftUI `ViewModifier` and a public `MediaPickerView`.
- Handle permissions, cancellation, unavailable hardware, and loading errors.
- Use Apple frameworks only, with no third-party dependencies.

## Requirements

- iOS 17 or later
- Swift 6
- Xcode with Swift 6 support
- Swift Package Manager

## Installation

In Xcode, select **File > Add Package Dependencies** and enter:

```text
https://github.com/Brenovisk/MediaPicker
```

Until the first tagged release is published, depend on the `main` branch. You
can also add the package to another Swift package:

```swift
dependencies: [
    .package(
        url: "https://github.com/Brenovisk/MediaPicker.git",
        branch: "main"
    )
]
```

Then add `MediaPicker` to the dependencies of your target:

```swift
.target(
    name: "YourApp",
    dependencies: ["MediaPicker"]
)
```

## Current API

The iOS camera view returns either a captured or library-selected photo through
the same `CapturedMedia` callback. Prepare camera access before presenting it:

```swift
import MediaPicker
import SwiftUI

CameraPreview(
    controlOptions: CameraPreviewControlOptions(
        mediaTypes: .photo,
        foregroundColor: .white,
        backgroundColor: .black,
        showsFlash: true,
        showsSwitchCamera: true,
        showsGallery: true,
        showsReview: true
    ),
    onCapture: { media in
        // Copy media.contentURL if the file must survive temporary cleanup.
    },
    onCancel: {}
)
```

Gallery selection uses the system photo picker and does not require full library
access. Setting `showsReview` to `false` delivers the result immediately. The
Photo/Video selector appears when both types are configured; video recording
is not available yet, so its shutter remains disabled.

## Planned API

The intended v0.0.1 call site is a SwiftUI modifier that presents the enabled
sources and returns one unified media result:

```swift
import MediaPicker
import SwiftUI

struct ContentView: View {
    @State private var isPickerPresented = false
    @State private var selectedMedia: CapturedMedia?

    var body: some View {
        Button("Add media") {
            isPickerPresented = true
        }
        .mediaPicker(
            isPresented: $isPickerPresented,
            sources: [.camera, .photoLibrary],
            mediaTypes: [.photo, .video]
        ) { result in
            selectedMedia = result
        }
    }
}
```

This example documents the planned design and does not compile against the
current scaffold yet.

## Development

Clone the repository and run the package checks from its root:

```sh
./.scripts/lint.sh
swift build
swift test
```

The lint command requires the SwiftLint version declared in
`.swiftlint-version`. SwiftLint is used only for development and CI and is not a
package dependency.

The example application is located in [`Example`](Example). It consumes the
local package and will be expanded as picker features are implemented.

To run package tests automatically before every push, install the repository's
version-controlled Git hooks once:

```sh
./.githooks/install-git-hooks.sh
```

Naming, formatting, Swift 6 concurrency, testing, branch, commit, and pull
request conventions are documented in [CONTRIBUTING.md](CONTRIBUTING.md).

## Project structure

```text
MediaPicker/
├── Package.swift
├── Sources/MediaPicker/
├── Tests/MediaPickerTests/
├── Example/
├── Docs/
├── Scripts/
└── .githooks/
```

The detailed scope, milestones, dependencies, acceptance criteria, and release
checklist are maintained in the [v0.0.1 roadmap](Docs/Roadmapv0.0.1.md).
The source-area responsibilities, dependency direction, access-control rules,
and concurrency ownership are documented in [Architecture](Docs/Architecture.md).

## Contributing and support

Read [CONTRIBUTING.md](CONTRIBUTING.md) before proposing a change. Questions,
bug reports, supported environments, and expected diagnostics are covered by
the [support policy](SUPPORT.md).

Suspected vulnerabilities must not be reported in a public issue. Use the
private process described in the [security policy](SECURITY.md).

## License

MediaPicker is available under the [MIT License](LICENSE).
