//
//  CaptureSessionOperations.swift
//  MediaPicker
//
//  Created by Breno Lucas on 09/09/26.
//

/**
 Injectable session commands used to test the actor without real hardware.

 This is a struct of closures instead of a protocol so the concrete storage stays
 behind a narrow interface and is not exposed to presentation or domain layers.
 Tests can replace individual operations without exposing `AVCaptureSession` or
 creating another session-controlling object that could bypass actor isolation.
*/
struct CaptureSessionOperations: Sendable {

    typealias ThrowingPositionCommand = @Sendable (CameraPosition) throws -> Void
    typealias SessionCommand = @Sendable () -> Void
    typealias ThrowingSessionCommand = @Sendable () throws -> Void
    typealias PositionCommand = @Sendable (CameraPosition) -> Void
    typealias LightingProvider = @Sendable () -> CameraLightingCapabilities
    typealias PhotoOutputCapabilitiesProvider = @Sendable () -> CameraPhotoOutputCapabilities
    typealias PhotoCaptureCommand = @Sendable (CameraFlashMode) async throws
        -> CameraPhotoCaptureRequest
    typealias TorchCommand = @Sendable (CameraTorchMode) throws -> Void
    typealias EventHandler = @Sendable (CameraSessionEvent) -> Void
    typealias EventObserver = @Sendable (@escaping EventHandler) -> Void

    let previewSession: CaptureSessionReference?

    let configure: ThrowingPositionCommand
    let reset: SessionCommand
    let startRunning: ThrowingSessionCommand
    let stopRunning: ThrowingSessionCommand

    let prepareCameraSwitch: PositionCommand
    let switchCamera: ThrowingPositionCommand
    let lightingCapabilities: LightingProvider
    let photoOutputCapabilities: PhotoOutputCapabilitiesProvider
    let capturePhoto: PhotoCaptureCommand
    let setTorchMode: TorchCommand

    let startObservingEvents: EventObserver
    let stopObservingEvents: SessionCommand

    init(
        previewSession: CaptureSessionReference? = nil,
        configure: @escaping ThrowingPositionCommand,
        reset: @escaping SessionCommand,
        startRunning: @escaping ThrowingSessionCommand,
        stopRunning: @escaping ThrowingSessionCommand,
        prepareCameraSwitch: @escaping PositionCommand,
        switchCamera: @escaping ThrowingPositionCommand,
        lightingCapabilities: @escaping LightingProvider = { .unavailable },
        photoOutputCapabilities: @escaping PhotoOutputCapabilitiesProvider = { .unavailable },
        capturePhoto: @escaping PhotoCaptureCommand = { _ in
            throw MediaPickerError.photoCaptureFailed
        },
        setTorchMode: @escaping TorchCommand = { _ in },
        startObservingEvents: @escaping EventObserver = { _ in },
        stopObservingEvents: @escaping SessionCommand = {}
    ) {
        self.previewSession = previewSession
        self.configure = configure
        self.reset = reset
        self.startRunning = startRunning
        self.stopRunning = stopRunning
        self.prepareCameraSwitch = prepareCameraSwitch
        self.switchCamera = switchCamera
        self.lightingCapabilities = lightingCapabilities
        self.photoOutputCapabilities = photoOutputCapabilities
        self.capturePhoto = capturePhoto
        self.setTorchMode = setTorchMode
        self.startObservingEvents = startObservingEvents
        self.stopObservingEvents = stopObservingEvents
    }

}
