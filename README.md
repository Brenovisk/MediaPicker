# MediaPicker

MediaPicker is a SwiftUI-first package for capturing photos and videos with the
camera or selecting them from the photo library through one consistent API.

> [!IMPORTANT]
> MediaPicker is in early development. The package foundation is available, but
> the camera, photo-library, and unified picker APIs described below are not yet
> implemented. Follow the [v0.0.1 roadmap](Docs/Roadmapv0.0.1.md) for progress.

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

The current public API is a small package-integration scaffold:

```swift
import MediaPicker

let message = MediaPicker().hello()
```

This placeholder will be replaced as the domain and picker APIs are implemented.

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
swift build
swift test
```

The example application is located in [`Example`](Example). It consumes the
local package and will be expanded as picker features are implemented.

To run package tests automatically before every push, install the repository's
version-controlled Git hooks once:

```sh
./Scripts/install-git-hooks.sh
```

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

## License

MediaPicker is available under the [MIT License](LICENSE).
