/**
 Injectable session commands used to test the actor without real hardware.

 This is a struct of closures instead of a protocol so the concrete storage can
 remain private and cannot be called directly outside `CaptureSessionService`.
 Tests can replace individual operations without exposing `AVCaptureSession` or
 creating another session-controlling object that could bypass actor isolation.
*/
struct CaptureSessionOperations: Sendable {

    let configure: @Sendable (CameraPosition) throws -> Void
    let startRunning: @Sendable () throws -> Void
    let stopRunning: @Sendable () throws -> Void

}
