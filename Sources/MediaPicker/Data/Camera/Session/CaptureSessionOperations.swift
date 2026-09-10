//
//  CaptureSessionOperations.swift
//  MediaPicker
//
//  Created by Breno Lucas on 09/09/26.
//

/**
 Injectable session commands used to test the actor without real hardware.

 This is a struct of closures instead of a protocol so the concrete storage can
 remain private and cannot be called directly outside `CaptureSessionService`.
 Tests can replace individual operations without exposing `AVCaptureSession` or
 creating another session-controlling object that could bypass actor isolation.
*/
struct CaptureSessionOperations: Sendable {

    let previewSession: CaptureSessionReference?
    let configure: @Sendable (CameraPosition) throws -> Void
    let reset: @Sendable () -> Void
    let startRunning: @Sendable () throws -> Void
    let stopRunning: @Sendable () throws -> Void
    let prepareCameraSwitch: @Sendable (CameraPosition) -> Void
    let switchCamera: @Sendable (CameraPosition) throws -> Void

    init(
        previewSession: CaptureSessionReference? = nil,
        configure: @escaping @Sendable (CameraPosition) throws -> Void,
        reset: @escaping @Sendable () -> Void,
        startRunning: @escaping @Sendable () throws -> Void,
        stopRunning: @escaping @Sendable () throws -> Void,
        prepareCameraSwitch: @escaping @Sendable (CameraPosition) -> Void,
        switchCamera: @escaping @Sendable (CameraPosition) throws -> Void
    ) {
        self.previewSession = previewSession
        self.configure = configure
        self.reset = reset
        self.startRunning = startRunning
        self.stopRunning = stopRunning
        self.prepareCameraSwitch = prepareCameraSwitch
        self.switchCamera = switchCamera
    }

}
