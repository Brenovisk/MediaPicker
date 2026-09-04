/**
 Represents the lifecycle of a camera capture session.

 `idle` means the camera component exists but has not been prepared or started.
 A failed state retains the stable module error that presentation code can show
 without depending on AVFoundation implementation details.
*/
enum CameraState: Sendable, Equatable {
    case idle
    case preparing
    case ready
    case capturingPhoto
    case recording
    case stoppingRecording
    case failed(MediaPickerError)
}
