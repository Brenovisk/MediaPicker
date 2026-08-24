# MediaPicker — Roadmap to v0.0.1

> Implementation plan for the first functional version of **MediaPicker**, a SwiftUI library for capturing and selecting photos and videos on iOS.

**Status:** Planning  
**Target version:** `0.0.1`  
**Platform:** iOS 17+  
**Language:** Swift 6  
**Distribution:** Swift Package Manager  
**External dependencies:** None

---

## Table of Contents

- [Overview](#overview)
- [v0.0.1 Goal](#v001-goal)
- [Project Principles](#project-principles)
- [v0.0.1 Scope](#v001-scope)
- [Out of Scope](#out-of-scope)
- [Global Definition of Done](#global-definition-of-done)
- [Milestones](#milestones)
- [Recommended Execution Sequence](#recommended-execution-sequence)
- [M0 — Package Foundation](#m0--package-foundation)
- [M1 — Media Domain](#m1--media-domain)
- [M2 — Camera Core](#m2--camera-core)
- [M3 — Photo Capture](#m3--photo-capture)
- [M4 — Video Capture](#m4--video-capture)
- [M5 — Photo Library](#m5--photo-library)
- [M6 — Unified MediaPicker API](#m6--unified-mediapicker-api)
- [M7 — Release v0.0.1](#m7--release-v001)
- [Final Release Checklist](#final-release-checklist)

---

## Overview

MediaPicker provides one SwiftUI API for two workflows:

1. capturing a photo or video with the camera;
2. selecting a photo or video from the system photo library.

The main v0.0.1 API will be a `ViewModifier`, because the picker represents a presentation flow similar to `.sheet`, `.photosPicker`, and `.fileImporter`:

```swift
Button("Add media") {
    isMediaPickerPresented = true
}
.mediaPicker(
    isPresented: $isMediaPickerPresented,
    sources: [.camera, .photoLibrary],
    mediaTypes: [.photo, .video]
) { result in
    selectedMedia = result
}
```

A public `MediaPickerView` will also be available for integrations that need to control presentation or embed the picker in a custom flow.

This roadmap follows dependency order. Every milestone must produce an executable, testable, or demonstrable result in the Example App before the next milestone begins.

---

## v0.0.1 Goal

Deliver a small, coherent, and usable first version that can:

- present the picker through a SwiftUI modifier;
- let users choose between camera and photo library when both are enabled;
- capture a photo;
- record a video with audio;
- select a photo or video from the library;
- return one unified result model for every source;
- cancel without producing a result;
- report permission, configuration, capture, recording, and loading failures;
- integrate through Swift Package Manager;
- demonstrate every supported flow in an Example App.

This version validates the product core and public API. Full source compatibility is not guaranteed before `1.0.0`.

---

## Project Principles

### SwiftUI-first

The public API should feel native to SwiftUI. State, presentation, completion, and cancellation should follow familiar platform conventions.

### Safe concurrency

Configuring and operating `AVCaptureSession` must not block the main thread. Capture infrastructure should isolate mutable state, while UI-observed updates happen on `MainActor`.

### Unified model

Consumers should not need to understand `AVFoundation`, `PhotosUI`, or `Transferable` to use picker results.

### Small API surface

Only types and operations required to use the library should be public. Infrastructure details remain internal.

### Zero dependencies

v0.0.1 uses system frameworks only, minimizing integration friction, binary impact, and supply-chain risk.

### Privacy by default

Permissions should be requested only when needed, with clear denied, restricted, and unavailable states.

### Verifiable delivery

Every issue should end with a successful build, relevant tests, and—when applicable—a manual demonstration in the Example App.

---

## v0.0.1 Scope

- Swift Package supporting iOS 17+ and Swift 6.
- Photo capture with front and back cameras.
- Video recording with audio.
- Single-item photo or video selection through `PhotosPicker`.
- Photo flash when supported.
- Front/back camera switching.
- Live camera preview.
- Unified photo and video result model.
- Camera, microphone, and photo-library permission flows.
- Public `ViewModifier` and `MediaPickerView` APIs.
- Example App for manual validation.
- Unit tests for domain and isolated business rules.
- Physical-device testing for camera and recording.
- README, changelog, and GitHub Release.

---

## Out of Scope

The following items do not block v0.0.1 and should be considered for future releases:

- support for iOS versions earlier than iOS 17;
- macOS, watchOS, tvOS, or visionOS;
- multiple selection from the photo library;
- simultaneous photo and video capture;
- editing, cropping, filters, drawing, or configurable compression;
- image crop or video trim;
- manual focus, exposure, ISO, white balance, or advanced zoom controls;
- ProRAW, RAW, Live Photos, depth data, or spatial capture;
- manual lens or capture-format selection;
- importing from Files, external cameras, or remote providers;
- uploading, cloud persistence, or gallery management;
- fully themeable UI;
- complete localization into multiple languages;
- accessibility certification beyond required baseline support;
- automated camera hardware testing in CI;
- API stability guarantees before `1.0.0`.

---

## Global Definition of Done

In addition to issue-specific criteria, an issue is complete only when:

- [ ] the code builds without new warnings on supported targets;
- [ ] public APIs have coherent names, access levels, and documentation;
- [ ] new isolated rules have unit tests;
- [ ] all existing tests still pass;
- [ ] relevant error and cancellation states are handled;
- [ ] required work is not hidden in `TODO` or `FIXME` comments;
- [ ] visible changes can be demonstrated in the Example App;
- [ ] affected documentation is updated;
- [ ] the pull request references the corresponding issue.

---

## Milestones

| Milestone | Issues | Expected outcome |
| --- | ---: | --- |
| M0 — Package Foundation | #1–#6 | Package, Example App, automation, and conventions ready |
| M1 — Media Domain | #7–#13 | UI-independent models and contracts |
| M2 — Camera Core | #14–#23 | Safe, functional camera session with preview |
| M3 — Photo Capture | #24–#29 | End-to-end photo capture |
| M4 — Video Capture | #30–#37 | End-to-end video recording with audio |
| M5 — Photo Library | #38–#43 | Library selection and content loading |
| M6 — Unified MediaPicker API | #44–#49 | Unified and documented public API |
| M7 — Release v0.0.1 | #50–#53 | QA, documentation, tag, and publication |

---

## Recommended Execution Sequence

The critical path is:

```text
M0 → M1 → M2 → M3 → M4 → M5 → M6 → M7
```

Within each milestone, follow issue order. The only recommended parallel work is:

- after #23, M3 and independent parts of M5 may proceed in parallel;
- after #29, M4 may proceed while isolated M5 tests are completed;
- preliminary work on #51 may happen during M6, but it should close only after the public API stabilizes in #49.

Do not begin final M6 integration until camera, photo, video, and library flows can each be demonstrated independently.

---

# M0 — Package Foundation

## Milestone Goal

Create the repository foundation so all development happens from the beginning as a distributable, testable library supported by an example application.

## Milestone Deliverable

The package builds, is imported by the Example App, runs tests locally, and validates pull requests automatically.

### Issue #1 — Create Swift Package

**Objective:** Create the initial MediaPicker package.

**Description:** Initialize a Swift Package Manager structure with a `MediaPicker` library target and a test target. Set iOS 17 as the minimum platform, Swift 6 as the language mode, and add no external dependencies.

Expected minimum structure:

```text
MediaPicker/
├── Package.swift
├── Sources/MediaPicker/
├── Tests/MediaPickerTests/
├── Example/
├── README.md
└── LICENSE
```

**Acceptance Criteria / Done:**

- [ ] `Package.swift` declares iOS 17+ and the `MediaPicker` product;
- [ ] `swift build` succeeds;
- [ ] `swift test` runs at least one initial test;
- [ ] a client target can use `import MediaPicker`;
- [ ] the package has no third-party dependencies.

**Depends on:** Nothing.  
**Order:** First issue in the project.

### Issue #2 — Add Example App

**Objective:** Create a minimal application for development and manual validation.

**Description:** Add a SwiftUI iOS app that consumes the local package. It will serve as the test bed for permissions, preview, capture, recording, library selection, and the public presentation API.

**Acceptance Criteria / Done:**

- [ ] the app launches in the simulator;
- [ ] the app imports the local `MediaPicker` target;
- [ ] a simple home screen exists for examples;
- [ ] the project can run on a physical device;
- [ ] the app does not duplicate internal library code.

**Depends on:** #1.  
**Order:** Immediately after package creation.

### Issue #3 — Define Project Structure and Module Boundaries

**Objective:** Establish a predictable code organization.

**Description:** Organize the target into areas such as `Domain`, `Camera`, `PhotoLibrary`, `Presentation`, and `Support`. Document which types may be public and prevent infrastructure frameworks from leaking into the consumer API.

**Acceptance Criteria / Done:**

- [ ] directories and responsibilities are defined;
- [ ] rules for `public`, `package`, and `internal` are documented;
- [ ] UI types do not own capture-session configuration;
- [ ] domain types do not depend on SwiftUI;
- [ ] the test target mirrors the relevant structure.

**Depends on:** #1.  
**Order:** Before domain model implementation.

### Issue #4 — Configure Continuous Integration

**Objective:** Automatically validate builds and tests.

**Description:** Add a GitHub Actions workflow that checks out the repository, selects a Swift 6-compatible Xcode version, and runs package build and tests for pull requests and pushes to the default branch.

**Acceptance Criteria / Done:**

- [ ] the workflow runs on pull requests;
- [ ] compilation failures fail the workflow;
- [ ] test failures fail the workflow;
- [ ] the selected Xcode version supports Swift 6;
- [ ] a CI badge can be added to the README.

**Depends on:** #1.  
**Order:** After the first successful local build and test.

### Issue #5 — Establish Code Style and Contribution Conventions

**Objective:** Define collaboration standards before the codebase grows.

**Description:** Document naming, formatting, concurrency, testing, branch, commit, and pull-request conventions. Add lightweight issue and PR templates. Linters must not become consumer dependencies.

**Acceptance Criteria / Done:**

- [ ] `CONTRIBUTING.md` exists;
- [ ] a pull-request template includes the Definition of Done;
- [ ] bug and feature issue templates exist;
- [ ] warning and formatting policies are documented;
- [ ] Swift 6 concurrency conventions are documented.

**Depends on:** #3.  
**Order:** Before multiple implementation tracks begin.

### Issue #6 — Add Repository Essentials

**Objective:** Make the repository ready for contribution and distribution.

**Description:** Add the initial README, maintainer-selected license, `.gitignore`, basic support and security policies, and minimum package metadata.

**Acceptance Criteria / Done:**

- [ ] `README.md` explains the purpose and current status;
- [ ] `LICENSE` contains the selected license;
- [ ] `.gitignore` covers Xcode and SwiftPM artifacts;
- [ ] `SECURITY.md` explains vulnerability reporting;
- [ ] derived files and local data are excluded from version control.

**Depends on:** #1 and #5.  
**Order:** Completes M0.

---

# M1 — Media Domain

## Milestone Goal

Define the models, states, configuration, and errors that form the shared contract between camera, photo library, and public API.

## Milestone Deliverable

A picker request and result can be represented without depending on SwiftUI, `AVCaptureSession`, or `PhotosPickerItem`.

### Issue #7 — Define MediaType

**Objective:** Represent media types accepted by the picker.

**Description:** Create a public type, preferably an `enum` or `OptionSet`, that expresses photo, video, or both. It must map internally to photo-library filters and camera capabilities.

**Acceptance Criteria / Done:**

- [ ] photo and video can be represented independently;
- [ ] enabling both is simple and unambiguous;
- [ ] the type is `Sendable` where applicable;
- [ ] it exposes no `PhotosUI` or `AVFoundation` types;
- [ ] valid combinations are tested.

**Depends on:** #3.  
**Order:** First domain model.

### Issue #8 — Define MediaSource

**Objective:** Represent available media sources.

**Description:** Create the public type for `.camera` and `.photoLibrary`, including combinations and predictable presentation order when both are enabled.

**Acceptance Criteria / Done:**

- [ ] camera and library can be configured independently;
- [ ] both can be enabled together;
- [ ] unsupported sources can be detected before presentation;
- [ ] the type is independent of the UI layer;
- [ ] combinations are tested.

**Depends on:** #3.  
**Order:** After #7.

### Issue #9 — Define CapturedMedia Result Model

**Objective:** Unify camera and photo-library results.

**Description:** Create a public `CapturedMedia` model containing the media type and a safe reference to its content, preferably a temporary URL or equivalent representation. Define minimum metadata, identity, ownership, and file lifetime.

**Acceptance Criteria / Done:**

- [ ] photos and videos use the same result model;
- [ ] source can be identified where useful;
- [ ] consumers can access content without importing internal frameworks;
- [ ] URL ownership and validity are documented;
- [ ] the model adopts `Sendable` and `Equatable` where technically correct;
- [ ] large payloads are not copied unnecessarily.

**Depends on:** #7 and #8.  
**Order:** Before capture and library services.

### Issue #10 — Define MediaPickerConfiguration

**Objective:** Centralize options supported in v0.0.1.

**Description:** Create a configuration containing sources, media types, and essential options such as initial camera and maximum video duration if included. Provide safe and useful defaults.

**Acceptance Criteria / Done:**

- [ ] the default configuration produces a valid flow;
- [ ] sources and accepted media types are configurable;
- [ ] invalid values do not silently reach infrastructure;
- [ ] defaults are documented;
- [ ] configuration is independent of SwiftUI.

**Depends on:** #7 and #8.  
**Order:** After the basic types.

### Issue #11 — Define MediaPickerError

**Objective:** Provide an understandable error taxonomy.

**Description:** Create a public error covering unavailability, denied permission, configuration, capture, recording, photo-library loading, unsupported format, and unknown failure. Preserve internal causes without exposing unstable implementation details.

**Acceptance Criteria / Done:**

- [ ] major failure flows have distinct cases;
- [ ] errors provide useful diagnostic descriptions;
- [ ] framework errors can be mapped internally;
- [ ] user cancellation is not treated as an error;
- [ ] the type is testable and documented.

**Depends on:** #7–#10.  
**Order:** Before service implementation.

### Issue #12 — Add Configuration Validation

**Objective:** Reject impossible combinations before starting the picker.

**Description:** Implement pure validation for empty sources, empty media types, unavailable camera, unsupported video, and invalid limits. Separate static configuration errors from dynamic device unavailability.

**Acceptance Criteria / Done:**

- [ ] empty sources are rejected;
- [ ] empty media types are rejected;
- [ ] invalid numeric limits are rejected;
- [ ] messages identify the problematic configuration;
- [ ] validation rules have unit tests.

**Depends on:** #10 and #11.  
**Order:** After configuration and error contracts.

### Issue #13 — Add Media Domain Test Suite

**Objective:** Stabilize the domain before infrastructure work.

**Description:** Add tests for models, defaults, combinations, validation, equality, pure internal conversions, and error semantics. Keep fixtures small and readable.

**Acceptance Criteria / Done:**

- [ ] every M1 type has relevant coverage;
- [ ] valid and invalid cases are tested;
- [ ] tests require no camera, library, or UI;
- [ ] the suite is deterministic in CI;
- [ ] core public contracts are captured by tests.

**Depends on:** #7–#12.  
**Order:** Completes M1.

---

# M2 — Camera Core

## Milestone Goal

Build shared photo and video infrastructure: authorization, device discovery, capture session, lifecycle, preview, camera switching, and failure recovery.

## Milestone Deliverable

The Example App opens a responsive camera preview, switches between front and back cameras, follows app lifecycle events, and displays permission or availability errors.

### Issue #14 — Implement Camera Authorization Service

**Objective:** Query and request camera access.

**Description:** Encapsulate `AVCaptureDevice.authorizationStatus(for:)` and asynchronous access requests. Map system states to an internal model that distinguishes undetermined, authorized, denied, and restricted.

**Acceptance Criteria / Done:**

- [ ] current status can be checked without requesting access;
- [ ] access is requested only when status is undetermined;
- [ ] denied and restricted states are distinct;
- [ ] UI updates occur on the correct actor;
- [ ] the Example App demonstrates relevant states;
- [ ] `NSCameraUsageDescription` is configured in the Example App.

**Depends on:** #11.  
**Order:** First camera-infrastructure issue.

### Issue #15 — Define CameraState and State Transitions

**Objective:** Explicitly model the camera lifecycle.

**Description:** Define states such as `idle`, `preparing`, `ready`, `capturingPhoto`, `recording`, `stoppingRecording`, and `failed`. `idle` means the camera exists but has not been prepared or started. Document valid transitions and prohibited actions.

**Acceptance Criteria / Done:**

- [ ] the initial state is `idle`;
- [ ] valid transitions are documented;
- [ ] commands incompatible with the current state are rejected;
- [ ] failures preserve enough information for the UI;
- [ ] tests cover nominal and invalid transitions.

**Depends on:** #11.  
**Order:** Before capture-session implementation.

### Issue #16 — Implement Camera Device Discovery

**Objective:** Locate compatible capture devices.

**Description:** Discover front and back cameras with predictable fallback among available device types. Advanced lens selection remains outside the v0.0.1 public API.

**Acceptance Criteria / Done:**

- [ ] the best available back camera is selected;
- [ ] the front camera is found when present;
- [ ] no camera produces an availability error;
- [ ] the simulator does not crash;
- [ ] device priority is documented and testable.

**Depends on:** #11 and #14.  
**Order:** Before configuring inputs.

### Issue #17 — Create Isolated Capture Session Service

**Objective:** Isolate mutable session state and blocking work.

**Description:** Create a capture service using appropriate isolation, such as an `actor` or dedicated serial executor. Configuration, start, stop, and input/output mutation must not block the main thread.

**Acceptance Criteria / Done:**

- [ ] all `AVCaptureSession` mutations are serialized;
- [ ] `startRunning()` and `stopRunning()` do not run on the main thread;
- [ ] the service satisfies Swift 6 strict concurrency;
- [ ] UI code does not mutate the session directly;
- [ ] failures map to domain errors.

**Depends on:** #15 and #16.  
**Order:** Foundation for all camera operations.

### Issue #18 — Configure Camera Session Inputs and Preset

**Objective:** Prepare a minimal functional capture session.

**Description:** Configure the session preset, video input, and structure for future outputs within `beginConfiguration` and `commitConfiguration`. Validate `canAddInput` and support safe rollback after partial failure.

**Acceptance Criteria / Done:**

- [ ] the session has a valid video input;
- [ ] the preset supports v0.0.1 photo and video flows;
- [ ] changes are grouped in a configuration transaction;
- [ ] partial failure does not corrupt session state;
- [ ] repeated configuration is idempotent or explicitly rejected.

**Depends on:** #17.  
**Order:** Before starting the session.

### Issue #19 — Implement Session Start, Stop, and App Lifecycle

**Objective:** Control camera use according to presentation and app lifecycle.

**Description:** Start the session while the camera picker is active, stop it when leaving or entering the background, and resume when appropriate. Prevent orphan sessions and concurrent initialization.

**Acceptance Criteria / Done:**

- [ ] opening the camera starts the session once;
- [ ] closing the camera stops the session;
- [ ] backgrounding does not leave capture active;
- [ ] foregrounding restores preview when possible;
- [ ] repeated calls cause no crash or race;
- [ ] transitions update `CameraState`.

**Depends on:** #18.  
**Order:** After minimal session configuration.

### Issue #20 — Build SwiftUI Camera Preview

**Objective:** Display the camera feed in SwiftUI.

**Description:** Wrap `AVCaptureVideoPreviewLayer` through the appropriate UIKit bridge. Configure video gravity, layout, orientation, and controlled session access without exposing mutation to the view.

**Acceptance Criteria / Done:**

- [ ] preview appears on a physical device;
- [ ] layout follows size changes;
- [ ] fill behavior is predictable;
- [ ] view updates do not recreate the session;
- [ ] unnecessary AVFoundation types do not leak into the public API.

**Depends on:** #18 and #19.  
**Order:** First visual camera result.

### Issue #21 — Implement Front and Back Camera Switching

**Objective:** Safely switch between available cameras.

**Description:** Replace the video input within a configuration transaction. Preserve the current camera if the new setup fails and prevent switching during incompatible operations.

**Acceptance Criteria / Done:**

- [ ] users can switch between front and back cameras;
- [ ] switching does not restart the entire presentation;
- [ ] failure restores the previous input;
- [ ] the control is disabled during incompatible capture or recording;
- [ ] the active camera is observable by the UI;
- [ ] front-camera mirroring is consistent.

**Depends on:** #18–#20.  
**Order:** After basic preview stability.

### Issue #22 — Add Flash and Torch Capability Model

**Objective:** Prepare hardware-aware lighting controls.

**Description:** Detect photo flash and video torch support, model supported modes, and provide safe internal operations. The UI should expose only capabilities available on the active device.

**Acceptance Criteria / Done:**

- [ ] flash and torch availability can be queried;
- [ ] unsupported modes are hidden or disabled;
- [ ] device locking is handled safely;
- [ ] switching cameras refreshes capabilities;
- [ ] simulator and no-flash devices do not fail.

**Depends on:** #16 and #21.  
**Order:** Before final photo and video controls.

### Issue #23 — Handle Camera Interruptions and Runtime Errors

**Objective:** Make the camera core resilient to system interruptions.

**Description:** Observe session interruptions and runtime errors, including camera-in-use conditions, availability changes, and media-services resets. Update state, recover only when safe, and communicate when user action is required.

**Acceptance Criteria / Done:**

- [ ] interruptions pause or disable controls correctly;
- [ ] runtime errors map to `MediaPickerError`;
- [ ] media-services reset can rebuild or restart the session;
- [ ] observers are removed during teardown;
- [ ] recovery cannot enter an infinite loop;
- [ ] reproducible scenarios are documented for manual testing.

**Depends on:** #19–#22.  
**Order:** Completes M2.

---

# M3 — Photo Capture

## Milestone Goal

Add photo capture on top of the camera core with correct orientation, UI feedback, unified result generation, and error handling.

## Milestone Deliverable

The Example App captures a photo from front and back cameras and returns a valid `CapturedMedia` value.

### Issue #24 — Add AVCapturePhotoOutput

**Objective:** Enable photo capture in the session.

**Description:** Create and add `AVCapturePhotoOutput` during session configuration. Validate support, select compatible settings, and keep integration encapsulated in the capture service.

**Acceptance Criteria / Done:**

- [ ] the output is added only when supported;
- [ ] failure does not invalidate the session;
- [ ] required capabilities can be queried internally;
- [ ] preview remains stable;
- [ ] output is ready before capture commands are accepted.

**Depends on:** #18 and #23.  
**Order:** First photo-capture issue.

### Issue #25 — Implement Photo Capture Command

**Objective:** Trigger capture with coherent settings.

**Description:** Implement asynchronous capture with flash when supported, a unique request identifier, and protection against unsupported simultaneous shots.

**Acceptance Criteria / Done:**

- [ ] capture is allowed only in `ready` state;
- [ ] state changes to `capturingPhoto` during capture;
- [ ] flash respects preference and device capability;
- [ ] repeated taps do not create invalid concurrent captures;
- [ ] success or failure completes exactly once.

**Depends on:** #15, #22, and #24.  
**Order:** After registering photo output.

### Issue #26 — Process Photo Capture Result

**Objective:** Convert AVFoundation callbacks into the domain result.

**Description:** Implement the photo delegate/processor, validate received data, write it to a controlled temporary location, and create `CapturedMedia`. Define a compatible extension and content type.

**Acceptance Criteria / Done:**

- [ ] callbacks match the correct request;
- [ ] empty or invalid data produces an error;
- [ ] consumers can open the resulting file;
- [ ] result type is `.photo` and source is `.camera`;
- [ ] state returns to `ready` after success or failure;
- [ ] partial files are removed.

**Depends on:** #9, #11, and #25.  
**Order:** Completes the capture pipeline.

### Issue #27 — Handle Photo Orientation and Mirroring

**Objective:** Produce visually correct images in supported orientations.

**Description:** Apply interface/device orientation to the capture connection and define front-camera mirroring behavior. Avoid obsolete APIs and document the selected policy.

**Acceptance Criteria / Done:**

- [ ] back-camera photos are not incorrectly rotated;
- [ ] front-camera photos follow the documented mirroring policy;
- [ ] rotation before capture updates the connection;
- [ ] portrait and landscape are tested on a device;
- [ ] preview and output behavior are coherent.

**Depends on:** #20, #21, and #26.  
**Order:** Before considering photo capture production-ready.

### Issue #28 — Build Photo Capture Controls and Feedback

**Objective:** Provide a minimal, accessible photo interface.

**Description:** Add capture, camera switching, flash mode, close/cancel, preparation state, and shutter feedback. Controls must follow `CameraState` and hardware capabilities.

**Acceptance Criteria / Done:**

- [ ] controls are active only in valid states;
- [ ] capture provides immediate feedback;
- [ ] flash control reflects the active mode;
- [ ] icons have accessibility labels;
- [ ] tap targets are adequate;
- [ ] safe areas and supported screen sizes are respected.

**Depends on:** #21, #22, #25, and #27.  
**Order:** After the functional pipeline.

### Issue #29 — Integrate and Test Photo Capture Flow

**Objective:** Validate photo capture end to end.

**Description:** Integrate service, state, preview, controls, and completion into the Example App. Add unit tests for isolated rules and a hardware-focused manual test matrix.

**Acceptance Criteria / Done:**

- [ ] back-camera photos are captured and displayed;
- [ ] front-camera photos are captured and displayed correctly;
- [ ] flash is tested on compatible hardware;
- [ ] cancellation produces no result;
- [ ] capture failure is shown without unexpected dismissal;
- [ ] another capture is possible after a recoverable failure;
- [ ] the manual test procedure is documented.

**Depends on:** #24–#28.  
**Order:** Completes M3.

---

# M4 — Video Capture

## Milestone Goal

Add video recording with audio, recording state, temporary-file management, correct orientation, and a minimal recording interface.

## Milestone Deliverable

The Example App starts and stops a recording, plays the resulting file, and returns valid `CapturedMedia`.

### Issue #30 — Add Movie File Output

**Objective:** Enable video recording in the capture session.

**Description:** Add `AVCaptureMovieFileOutput` or the equivalent selected v0.0.1 strategy. Configure it without breaking photo output and query codec or duration support when applicable.

**Acceptance Criteria / Done:**

- [ ] video output is added when supported;
- [ ] photo and video can share the configured session;
- [ ] unavailable output produces a predictable error;
- [ ] output is not recreated for every recording;
- [ ] capabilities remain encapsulated.

**Depends on:** #23 and #24.  
**Order:** First video issue.

### Issue #31 — Implement Microphone Authorization and Audio Input

**Objective:** Record video with audio when authorized.

**Description:** Query and request microphone permission only when entering a video-capable flow. Discover the audio device, create its input, and add it with safe rollback.

**Acceptance Criteria / Done:**

- [ ] microphone permission is not requested for photo-only flows;
- [ ] `NSMicrophoneUsageDescription` exists in the Example App;
- [ ] audio input is added when authorized and supported;
- [ ] denied/restricted behavior is documented and reported;
- [ ] audio input failure does not corrupt the session;
- [ ] status can be reflected in the UI.

**Depends on:** #11, #14, #18, and #30.  
**Order:** Before recording begins.

### Issue #32 — Implement Video Recording Lifecycle

**Objective:** Start and stop recordings safely.

**Description:** Create start and stop commands tied to camera state, prevent conflicting operations, and bridge output callbacks to async/await or an equivalent internal mechanism.

**Acceptance Criteria / Done:**

- [ ] recording starts only in `ready` state;
- [ ] state changes to `recording` after a valid start;
- [ ] stop is accepted only during recording;
- [ ] completion occurs exactly once;
- [ ] camera switching and photo capture are blocked during recording;
- [ ] errors restore a coherent state.

**Depends on:** #15, #30, and #31.  
**Order:** After video and audio outputs.

### Issue #33 — Add Recording State, Duration, and Limits

**Objective:** Expose enough progress for the recording UI.

**Description:** Maintain observable duration, expose starting/stopping states, and enforce a configured maximum duration if supported. Cancel timers when recording ends, fails, or the picker is dismissed.

**Acceptance Criteria / Done:**

- [ ] duration starts at zero and advances only while recording;
- [ ] the counter stops and resets correctly;
- [ ] the configured limit stops recording cleanly;
- [ ] duplicate timers cannot be created;
- [ ] duration formatting is tested independently.

**Depends on:** #10 and #32.  
**Order:** After basic start/stop.

### Issue #34 — Manage Video Temporary Files

**Objective:** Produce valid files without accumulating leftovers.

**Description:** Generate a unique URL before every recording, avoid collisions, validate the final file, and create `CapturedMedia`. Document that consumers must copy files they want to retain.

**Acceptance Criteria / Done:**

- [ ] every recording gets a unique URL;
- [ ] files are never overwritten silently;
- [ ] partial files are removed after failure;
- [ ] the final file exists and is non-empty;
- [ ] result type is `.video` and source is `.camera`;
- [ ] cleanup policy is documented.

**Depends on:** #9, #11, and #32.  
**Order:** Before returning video results.

### Issue #35 — Handle Video Orientation and Mirroring

**Objective:** Save videos with correct orientation and mirroring.

**Description:** Configure the video connection when recording begins, keep orientation stable throughout the file, and apply the front-camera policy established for photos.

**Acceptance Criteria / Done:**

- [ ] portrait videos play correctly;
- [ ] landscape videos play correctly;
- [ ] front-camera output follows the documented policy;
- [ ] rotation during recording does not corrupt the file;
- [ ] the Example App player confirms output correctness.

**Depends on:** #27, #32, and #34.  
**Order:** After producing the first playable file.

### Issue #36 — Build Video Recording Controls and Feedback

**Objective:** Provide a clear interface for starting and stopping recording.

**Description:** Add a stateful recording button, duration, stop action, cancellation, and preparation/error indicators. Block incompatible actions while the file is being finalized.

**Acceptance Criteria / Done:**

- [ ] start and stop have distinct visual feedback;
- [ ] duration appears during recording;
- [ ] incompatible controls are disabled;
- [ ] accidental dismissal is prevented during finalization;
- [ ] accessibility labels reflect recording state;
- [ ] layout works on supported screen sizes.

**Depends on:** #33–#35.  
**Order:** After stabilizing the recording pipeline.

### Issue #37 — Integrate and Test Video Capture Flow

**Objective:** Validate video end to end on physical hardware.

**Description:** Integrate authorization, audio, recording, duration, files, orientation, UI, and completion. Test interruptions, storage failures, denied permission, and cancellation where applicable.

**Acceptance Criteria / Done:**

- [ ] back-camera video with audio records and plays;
- [ ] front-camera video records and plays correctly;
- [ ] repeated start/stop causes no race or crash;
- [ ] cancellation before recording produces no result;
- [ ] recording failure removes partial files;
- [ ] duration limit works if exposed;
- [ ] the manual procedure covers interruptions and backgrounding;
- [ ] isolated rules have unit tests.

**Depends on:** #30–#36.  
**Order:** Completes M4.

---

# M5 — Photo Library

## Milestone Goal

Integrate `PhotosPicker` to select a photo or video, load it asynchronously, and convert it to the same result model used by the camera.

## Milestone Deliverable

The Example App selects a photo or video, displays loading progress, and returns `CapturedMedia` without publicly exposing `PhotosPickerItem`.

### Issue #38 — Add PhotosPicker Presentation Adapter

**Objective:** Create the initial bridge to the system photo library.

**Description:** Encapsulate `PhotosPicker` presentation in an internal implementation that the future `MediaPickerView` can trigger. v0.0.1 supports single selection.

**Acceptance Criteria / Done:**

- [ ] the system picker can be presented and dismissed;
- [ ] only one item can be selected;
- [ ] cancellation closes without an error;
- [ ] `PhotosPickerItem` does not appear in public API;
- [ ] implementation works in simulator and on device.

**Depends on:** #2, #8, and #11.  
**Order:** May begin after M1; integrate fully after M2.

### Issue #39 — Map Media Types to PhotosPicker Filters

**Objective:** Respect configured types when opening the library.

**Description:** Convert `MediaType` to `PHPickerFilter` for photo, video, and both. Keep conversion internal and reject empty configurations early.

**Acceptance Criteria / Done:**

- [ ] photo mode shows compatible images only;
- [ ] video mode shows compatible videos only;
- [ ] combined mode uses a combined filter;
- [ ] empty configuration is rejected;
- [ ] pure conversions have tests.

**Depends on:** #7, #12, and #38.  
**Order:** After basic presentation.

### Issue #40 — Load Selected Item Asynchronously

**Objective:** Load selected content without blocking the UI.

**Description:** Use `PhotosPickerItem` Transferable APIs to obtain a safe representation. Prefer file transfer for videos and avoid holding large data in memory unnecessarily.

**Acceptance Criteria / Done:**

- [ ] loading does not block synchronous UI work;
- [ ] selected photos are materialized successfully;
- [ ] selected videos are materialized successfully;
- [ ] unsupported formats produce explicit errors;
- [ ] a new selection safely cancels or replaces prior loading;
- [ ] task cancellation is not shown as a user-facing error.

**Depends on:** #11, #38, and #39.  
**Order:** Core library-selection flow.

### Issue #41 — Convert Library Selection to CapturedMedia

**Objective:** Unify photo-library output with camera output.

**Description:** Copy or move loaded content to a controlled temporary URL, identify its actual type, validate compatibility, and create `CapturedMedia` with `.photoLibrary` as the source.

**Acceptance Criteria / Done:**

- [ ] library photos produce photo results;
- [ ] library videos produce video results;
- [ ] source is identified as photo library;
- [ ] final URL remains accessible after the loading callback;
- [ ] extension and type match the content;
- [ ] failed-operation leftovers are removed.

**Depends on:** #9 and #40.  
**Order:** After asynchronous loading.

### Issue #42 — Handle Library Loading, Cancellation, and Errors

**Objective:** Provide predictable states during import.

**Description:** Model idle, selection, loading, success, cancellation, and failure. Display indeterminate progress where needed, support safe cancellation, and map failures to `MediaPickerError`.

**Acceptance Criteria / Done:**

- [ ] UI indicates when an item is loading;
- [ ] repeated selections cannot return out of order;
- [ ] cancellation does not display an error alert;
- [ ] recoverable failures can be retried;
- [ ] a result is delivered exactly once;
- [ ] tasks are canceled when presentation ends.

**Depends on:** #11 and #40–#41.  
**Order:** Before final integration.

### Issue #43 — Integrate and Test Photo Library Flow

**Objective:** Validate photo-library selection end to end.

**Description:** Integrate filters, selection, loading, state, and results in the Example App. Test iCloud-backed items, common formats, cancellation, and large files where the environment permits.

**Acceptance Criteria / Done:**

- [ ] selected photos are displayed in the Example App;
- [ ] selected videos can be played;
- [ ] filters match configuration;
- [ ] cancellation produces no result;
- [ ] unavailable items or network failure produce recoverable errors;
- [ ] `PhotosPickerItem` is not exposed to the client app;
- [ ] conversion rules and manual scenarios are tested.

**Depends on:** #38–#42.  
**Order:** Completes M5.

---

# M6 — Unified MediaPicker API

## Milestone Goal

Combine the working flows into one experience and expose the v0.0.1 public SwiftUI API.

## Milestone Deliverable

A client app can present MediaPicker through a modifier or view, restrict sources and media types, receive one result, cancel, and handle errors.

### Issue #44 — Build Source Selection Flow

**Objective:** Select or determine the media source.

**Description:** When camera and library are enabled, present a simple source choice. When only one is enabled, open it directly. Hide unavailable sources or explain their unavailability as appropriate.

**Acceptance Criteria / Done:**

- [ ] a single source opens directly;
- [ ] two sources present a clear choice;
- [ ] canceling the choice cancels the picker;
- [ ] an unavailable camera does not crash;
- [ ] source order is predictable;
- [ ] actions have baseline accessibility support.

**Depends on:** #8, #12, #29, #37, and #43.  
**Order:** Begins flow unification.

### Issue #45 — Implement Public MediaPickerView

**Objective:** Provide a public view for controlled presentation.

**Description:** Create `MediaPickerView` as the container for source selection, camera, photo, video, and photo-library flows. It accepts configuration and coherent success, cancellation, and error contracts.

**Acceptance Criteria / Done:**

- [ ] the view works inside `.sheet` or `.fullScreenCover`;
- [ ] configured sources and types are respected;
- [ ] success returns exactly one `CapturedMedia`;
- [ ] cancellation returns no media;
- [ ] errors are not confused with cancellation;
- [ ] AVFoundation and PhotosUI details remain hidden.

**Depends on:** #44.  
**Order:** Public foundation used by the modifier.

### Issue #46 — Implement `.mediaPicker` ViewModifier

**Objective:** Create the primary SwiftUI-style API.

**Description:** Implement a public modifier controlled by `Binding<Bool>`, accepting parameters or `MediaPickerConfiguration`. Use an appropriate presentation style and keep the binding synchronized.

Desired usage:

```swift
.mediaPicker(
    isPresented: $isPresented,
    sources: [.camera, .photoLibrary],
    mediaTypes: [.photo, .video],
    onCompletion: { media in
        selectedMedia = media
    }
)
```

**Acceptance Criteria / Done:**

- [ ] setting `isPresented` to `true` opens the picker;
- [ ] dismissal resets the binding;
- [ ] success closes the presentation and returns a result;
- [ ] cancellation closes without a result;
- [ ] the modifier reuses `MediaPickerView`;
- [ ] consecutive presentations do not retain stale state;
- [ ] the public signature has DocC documentation.

**Depends on:** #45.  
**Order:** After `MediaPickerView` stabilizes.

### Issue #47 — Finalize Completion, Cancellation, and Error Contracts

**Objective:** Remove ambiguity from terminal API events.

**Description:** Formally define whether the API uses separate closures or `Result`, how cancellation is signaled, and when presentation ends. Ensure success, failure, and cancellation are mutually exclusive.

**Acceptance Criteria / Done:**

- [ ] each presentation emits at most one terminal event;
- [ ] cancellation is not a `MediaPickerError`;
- [ ] recoverable errors preserve retry behavior;
- [ ] the binding remains synchronized in every path;
- [ ] camera and library follow the same contract;
- [ ] tests cover success, failure, cancellation, and external dismissal.

**Depends on:** #45 and #46.  
**Order:** Before freezing the public signature.

### Issue #48 — Unify Permission and Error Presentation

**Objective:** Provide a consistent experience for failures from both sources.

**Description:** Create reusable presentation for denied permission, unavailable resources, recoverable failure, and terminal failure. Offer a Settings action where appropriate without coupling user-facing text to the error model.

**Acceptance Criteria / Done:**

- [ ] denied camera access shows clear guidance;
- [ ] denied microphone access is explained in video flows;
- [ ] photo-library failures use the same visual language;
- [ ] Settings appears only when relevant;
- [ ] retry does not create overlapping presentations;
- [ ] essential messages are accessible.

**Depends on:** #14, #23, #31, #42, and #47.  
**Order:** After terminal-event contracts.

### Issue #49 — Polish and Document the Public API

**Objective:** Prepare the public contract for the first release.

**Description:** Audit naming, access control, defaults, availability, `Sendable`, DocC, and call-site ergonomics. Update the Example App with camera-only, library-only, and combined examples.

**Acceptance Criteria / Done:**

- [ ] only required types are public;
- [ ] accidental infrastructure symbols are not public;
- [ ] every public symbol is documented;
- [ ] modifier and view examples compile;
- [ ] defaults produce a valid experience;
- [ ] the Example App demonstrates photo, video, library, and combined modes;
- [ ] strict-concurrency builds introduce no warnings;
- [ ] the candidate API is recorded in the changelog.

**Depends on:** #44–#48.  
**Order:** Completes M6 and establishes the release candidate.

---

# M7 — Release v0.0.1

## Milestone Goal

Validate the release candidate, complete documentation, and publish a reproducible Swift Package Manager release.

## Milestone Deliverable

Tag `0.0.1` is published, installable, and documented well enough for a developer to integrate and test the library.

### Issue #50 — Execute Release Candidate QA Matrix

**Objective:** Systematically validate all flows before publication.

**Description:** Run automated tests and a manual matrix on available simulators and physical devices. Cover supported iOS versions, screen sizes, orientations, cameras, permissions, backgrounding, interruptions, and library files.

**Acceptance Criteria / Done:**

- [ ] build and tests pass in a clean environment;
- [ ] local SwiftPM installation is validated;
- [ ] front and back cameras are tested on a device;
- [ ] photo with and without flash is tested when supported;
- [ ] video with audio records and plays;
- [ ] library selection is tested with photo and video;
- [ ] granted, denied, and previously denied permissions are tested;
- [ ] cancellation is tested at every applicable stage;
- [ ] no known crash, deadlock, or critical warning remains;
- [ ] blocking bugs are fixed and retested.

**Depends on:** #49.  
**Order:** First release-candidate step.

### Issue #51 — Complete README and Usage Documentation

**Objective:** Enable integration without reading source code.

**Description:** Finalize the README with requirements, installation, privacy keys, quick start, configuration, result/error handling, `MediaPickerView`, limitations, troubleshooting, and contribution guidance.

**Acceptance Criteria / Done:**

- [ ] iOS, Swift, and Xcode requirements are explicit;
- [ ] SwiftPM installation instructions are correct;
- [ ] `NSCameraUsageDescription` and `NSMicrophoneUsageDescription` are explained;
- [ ] quick-start code compiles without hidden steps;
- [ ] photo, video, and library examples are included;
- [ ] temporary-file lifetime is documented;
- [ ] v0.0.1 limitations are listed;
- [ ] license, contribution, and security documents are linked.

**Depends on:** #49 and relevant findings from #50.  
**Order:** Close after API and QA stabilize.

### Issue #52 — Prepare Version Metadata and Changelog

**Objective:** Prepare all `0.0.1` release metadata.

**Description:** Review `Package.swift`, add the version to the changelog, list features and limitations, prepare release notes, and confirm that the candidate commit contains no local artifacts or secrets.

**Acceptance Criteria / Done:**

- [ ] `CHANGELOG.md` contains a dated `0.0.1` section;
- [ ] notes distinguish features, fixes, and limitations;
- [ ] `Package.swift` references valid files and targets only;
- [ ] the repository contains no credentials or local data;
- [ ] CI is green on the default branch;
- [ ] the release commit is identified and approved.

**Depends on:** #50 and #51.  
**Order:** Immediately before tagging.

### Issue #53 — Publish GitHub Release v0.0.1

**Objective:** Publish the first installable MediaPicker version.

**Description:** Create an immutable SemVer tag, publish the GitHub Release with prepared notes, and validate the remote dependency from a clean consumer project using the repository URL.

**Acceptance Criteria / Done:**

- [ ] annotated tag `0.0.1` points to the approved commit;
- [ ] GitHub Release is published with notes and limitations;
- [ ] the release is not labeled latest stable if project policy treats `0.x` as experimental;
- [ ] a clean app resolves `0.0.1` through SwiftPM;
- [ ] the clean app builds and presents the picker;
- [ ] completed issues are closed or moved to the next release;
- [ ] known next steps are recorded without expanding v0.0.1 retroactively.

**Depends on:** #52.  
**Order:** Final v0.0.1 issue.

---

## Final Release Checklist

### Product

- [ ] `.mediaPicker` opens and closes correctly.
- [ ] `MediaPickerView` works in app-controlled presentation.
- [ ] Camera-only configuration skips source selection.
- [ ] Library-only configuration skips source selection.
- [ ] Enabling both sources presents a source choice.
- [ ] Photos can be captured with front and back cameras.
- [ ] Video with audio can be recorded and played.
- [ ] Photos and videos can be selected from the library.
- [ ] Every flow returns `CapturedMedia`.
- [ ] Cancellation is never reported as success or failure.
- [ ] Every presentation emits at most one terminal event.

### Permissions and Resilience

- [ ] Authorized, denied, restricted, and undetermined camera states were verified.
- [ ] Authorized, denied, restricted, and undetermined microphone states were verified.
- [ ] Usage descriptions are documented and present in the Example App.
- [ ] Background and foreground transitions do not corrupt session state.
- [ ] Interruptions and runtime errors do not crash the app.
- [ ] A simulator without a camera reports unavailability correctly.
- [ ] Partial and temporary files follow the documented policy.

### Quality

- [ ] The package builds with Swift 6 and iOS 17+.
- [ ] Strict concurrency introduces no new warnings.
- [ ] All automated tests pass locally and in CI.
- [ ] The manual matrix was run on at least one physical device.
- [ ] No blocking bugs remain open.
- [ ] Accidental public APIs were removed.
- [ ] Every public symbol has documentation.
- [ ] The Example App covers every advertised scenario.

### Documentation and Distribution

- [ ] README contains valid installation and quick-start instructions.
- [ ] Requirements and privacy keys are documented.
- [ ] Limitations and out-of-scope items are explicit.
- [ ] `CHANGELOG.md` contains version `0.0.1`.
- [ ] License and contribution guide are present.
- [ ] CI is green on the release commit.
- [ ] Tag `0.0.1` was created from the correct commit.
- [ ] The GitHub Release was published.
- [ ] The remote version resolves in a clean consumer app.

---

## Expected Result

When all 53 issues and the final checklist are complete, MediaPicker v0.0.1 will have a clear architecture, functional camera and photo-library flows, a coherent SwiftUI API, and enough documentation for public use and continued development.
