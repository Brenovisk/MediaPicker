/** An event that may move the camera to another lifecycle state. */
enum CameraEvent: Sendable, Equatable {
    case prepare
    case preparationSucceeded
    case suspend
    case resume
    case interruptionBegan(CameraSessionEvent.InterruptionReason)
    case interruptionEnded
    case capturePhoto
    case photoCaptured
    case startRecording
    case stopRecording
    case recordingStopped
    case fail(MediaPickerError)
    case reset
}
