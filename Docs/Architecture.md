# MediaPicker Architecture

MediaPicker is distributed as a single Swift Package target. The directories
below organize responsibilities inside that target; they are not separate Swift
modules. This keeps v0.0.1 small while making dependencies and ownership clear.

## Source areas

### Domain

Framework-independent models and rules shared by every picker flow. This area
is organized by functional context instead of one global folder per technical
type:

```text
Domain/
├── Camera/
│   ├── Entities/
│   ├── Protocols/
│   ├── StateMachine/
│   └── UseCases/
├── Media/
│   └── Entities/
└── Picker/
    ├── Constants/
    ├── Entities/
    └── Errors/
```

`Camera` contains camera rules and operations, `Media` contains values shared by
camera and photo-library flows, and `Picker` contains configuration and errors
for the public picker workflow. New files should be placed by the behavior they
belong to, using a technical subfolder only when that context needs one.

Domain code must not import SwiftUI, AVFoundation, PhotosUI, or UIKit.

### Data

Concrete integrations with system frameworks. `Data/Camera` owns camera
authorization, device discovery, capture-session isolation, photo capture, and
video recording. `Data/PhotoLibrary` owns PhotosPicker integration, filters,
asynchronous item loading, and result conversion. AVFoundation, PhotosUI, and
their related types remain implementation details.

The camera state machine belongs to `Domain/Camera` because it expresses
lifecycle rules without depending on AVFoundation.

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
Presentation  -> Data

Data          -> Domain
Data          -> Support

Support       -> Domain (only when necessary)
Domain        -> Foundation only
```

Dependencies in the opposite direction are not allowed. In particular, Domain
must not know about Presentation or system capture frameworks, and Data must not
depend on Presentation.

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
