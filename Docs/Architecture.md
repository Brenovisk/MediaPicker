# MediaPicker Architecture

MediaPicker is distributed as a single Swift Package target. The directories
below organize responsibilities inside that target; they are not separate Swift
modules. This keeps v0.0.1 small while making dependencies and ownership clear.

## Source areas

### Domain

Framework-independent models and rules shared by every picker flow. This area
will contain types such as `MediaType`, `MediaSource`, `CapturedMedia`,
`MediaPickerConfiguration`, and `MediaPickerError`.

Domain code must not import SwiftUI, AVFoundation, PhotosUI, or UIKit.

### Camera

Camera authorization, device discovery, capture-session isolation, preview
integration, photo capture, and video recording. AVFoundation types remain
implementation details and must not appear in the public consumer API.

### PhotoLibrary

PhotosPicker presentation, filters, asynchronous item loading, and conversion
to domain results. PhotosUI and `PhotosPickerItem` remain implementation details.

### Presentation

The public `MediaPickerView`, the `.mediaPicker` modifier, source selection,
and user-facing controls and states. Presentation code may observe camera state,
but must not configure or mutate `AVCaptureSession` directly.

### Support

Focused shared infrastructure such as temporary-file management, content-type
inspection, internal conversions, and logging. A helper belongs here only when
it is used by more than one feature area and has a clearly defined purpose.

## Dependency direction

Allowed dependencies are:

```text
Presentation  -> Domain
Presentation  -> Camera
Presentation  -> PhotoLibrary

Camera        -> Domain
Camera        -> Support

PhotoLibrary  -> Domain
PhotoLibrary  -> Support

Support       -> Domain (only when necessary)
Domain        -> Foundation only
```

Dependencies in the opposite direction are not allowed. In particular, Domain
must not know about presentation or system capture frameworks, and Camera and
PhotoLibrary must not depend on Presentation.

## Access control

- Use `public` only for symbols required by a client integrating MediaPicker.
- Use `package` only for sharing implementation across package targets if the
  package gains additional targets in the future.
- Use `internal` by default for implementation shared within the library.
- Use `private` or `fileprivate` for details owned by one declaration or file.
- Do not make implementation public to enable tests. Tests use
  `@testable import MediaPicker` when internal access is required.

Public domain types must not expose AVFoundation, PhotosUI, SwiftUI, or UIKit
types unless the type itself is explicitly part of the SwiftUI presentation API.

## Concurrency ownership

Blocking capture-session operations and all mutations of `AVCaptureSession`
must be serialized outside the main actor. UI-observed state and SwiftUI-facing
operations run on `MainActor`. Values crossing isolation boundaries should be
`Sendable` whenever technically correct.

## Tests

`Tests/MediaPickerTests` mirrors the source areas for tests of domain rules,
camera state and isolated services, photo-library conversions, presentation
contracts, and support utilities. Hardware-dependent camera behavior is covered
by documented manual tests in the Example App rather than assumed to work in CI.
