//
//  CaptureSessionService.swift
//  MediaPicker
//
//  Created by Breno Lucas on 09/09/26.
//

import Dispatch

/**
 Serializes all mutable capture-session work away from the main thread.

 The service owns a dedicated serial executor. Calls may originate from UI code,
 but session operations always execute on this actor. Presentation code receives
 only asynchronous commands and never accesses `AVCaptureSession` directly.
*/
actor CaptureSessionService: CameraSessionControlling {

    nonisolated private let executor: DispatchSerialQueue
    nonisolated let previewSession: CaptureSessionReference?

    let operations: CaptureSessionOperations
    let updateStream: AsyncStream<CameraSessionSnapshot>
    let updateContinuation: AsyncStream<CameraSessionSnapshot>.Continuation

    var stateMachine = CameraStateMachine()
    var configuredPosition: CameraPosition?

    var lightingCapabilities: CameraLightingCapabilities = .unavailable
    var photoOutputCapabilities: CameraPhotoOutputCapabilities = .unavailable
    var flashMode: CameraFlashMode = .off
    var torchMode: CameraTorchMode = .off

    var isPickerActive = false
    var isSessionRunning = false
    var isObservingEvents = false
    var didAttemptRecovery = false

    var state: CameraState { stateMachine.state }
    var activeCameraPosition: CameraPosition? { configuredPosition }
    var canSwitchCamera: Bool { state == .ready }
    var canCapturePhoto: Bool { state == .ready && photoOutputCapabilities.isAvailable }

    nonisolated var unownedExecutor: UnownedSerialExecutor {
        executor.asUnownedSerialExecutor()
    }

    init(operations: CaptureSessionOperations = .live) {
        let updates = AsyncStream<CameraSessionSnapshot>.makeStream(
            bufferingPolicy: .bufferingNewest(1)
        )

        executor = DispatchSerialQueue(
            label: MediaPickerInfrastructureConstants.captureSessionQueueLabel
        )
        previewSession = operations.previewSession
        self.operations = operations
        updateStream = updates.stream
        updateContinuation = updates.continuation
    }

    deinit {
        operations.stopObservingEvents()
        updateContinuation.finish()
    }

}
