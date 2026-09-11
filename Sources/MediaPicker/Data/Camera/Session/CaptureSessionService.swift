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

 Future input, output, and configuration mutations must be implemented as actor
 methods here to preserve this isolation.
*/
actor CaptureSessionService: CameraSessionControlling {

    nonisolated private let executor: DispatchSerialQueue
    nonisolated let previewSession: CaptureSessionReference?

    let operations: CaptureSessionOperations
    let updateStream: AsyncStream<CameraSessionSnapshot>
    let updateContinuation: AsyncStream<CameraSessionSnapshot>.Continuation

    var stateMachine = CameraStateMachine()
    private var configuredPosition: CameraPosition?

    private(set) var lightingCapabilities: CameraLightingCapabilities = .unavailable
    private(set) var flashMode: CameraFlashMode = .off
    private(set) var torchMode: CameraTorchMode = .off

    var isPickerActive = false
    var isSessionRunning = false
    var isObservingEvents = false
    private var didAttemptRecovery = false

    var state: CameraState {
        stateMachine.state
    }

    var activeCameraPosition: CameraPosition? {
        configuredPosition
    }

    var canSwitchCamera: Bool {
        state == .ready
    }

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

    func configure(for position: CameraPosition) throws {
        guard configuredPosition != position else { return }

        guard configuredPosition == nil else {
            throw MediaPickerError.captureSessionConfigurationFailed
        }

        do {
            try operations.configure(position)
            configuredPosition = position
        } catch let error as MediaPickerError {
            throw error
        } catch {
            throw MediaPickerError.captureSessionConfigurationFailed
        }
    }

    func open(for position: CameraPosition) throws {
        isPickerActive = true
        startObservingEvents()

        do {
            switch state {
            case .ready:
                return
            case .suspended:
                try resumeSession()
            case .idle, .failed:
                try prepareSession(for: position)
            case .interrupted, .preparing, .capturingPhoto,
                 .recording, .stoppingRecording:
                throw CameraStateTransitionError(state: state, event: .prepare)
            }
        } catch {
            stopObservingEvents()
            throw error
        }
    }

    func close() throws {
        isPickerActive = false
        stopObservingEvents()
        didAttemptRecovery = false

        guard requiresClosing else { return }

        try stopSessionHandlingFailure()
        resetSession()

        try stateMachine.handle(.reset)
    }

    func applicationDidEnterBackground() throws {
        guard isPickerActive, isSessionRunning else { return }

        do {
            try stopSession()
            try stateMachine.handle(.suspend)
        } catch let error as MediaPickerError {
            try? stateMachine.handle(.fail(error))
            throw error
        }
    }

    func applicationWillEnterForeground() throws {
        guard isPickerActive, state == .suspended else { return }
        try resumeSession()
    }

    @discardableResult
    func switchCamera() throws -> CameraPosition {
        guard canSwitchCamera, let configuredPosition else {
            throw MediaPickerError.captureSessionSwitchFailed
        }

        let newPosition = configuredPosition.opposite

        do {
            try operations.switchCamera(newPosition)
            self.configuredPosition = newPosition
            refreshLightingCapabilities()
            return newPosition
        } catch let error as MediaPickerError {
            throw error
        } catch {
            throw MediaPickerError.captureSessionSwitchFailed
        }
    }

    func setFlashMode(_ mode: CameraFlashMode) throws {
        guard lightingCapabilities.flashModes.contains(mode) else {
            throw MediaPickerError.unsupportedFlashMode
        }

        flashMode = mode
    }

    func setTorchMode(_ mode: CameraTorchMode) throws {
        guard lightingCapabilities.torchModes.contains(mode) else {
            throw MediaPickerError.unsupportedTorchMode
        }

        do {
            try operations.setTorchMode(mode)
            torchMode = mode
        } catch {
            throw MediaPickerError.cameraDeviceConfigurationFailed
        }
    }

}

// MARK: Helper Methods
extension CaptureSessionService {

    // MARK: Recovery

    func recoverFromMediaServicesReset() {
        guard didAttemptRecovery == false, let position = configuredPosition else {
            try? stateMachine.handle(.fail(.mediaServicesResetRecoveryFailed))
            return
        }

        didAttemptRecovery = true
        isSessionRunning = false
        try? stateMachine.handle(.fail(.captureSessionRuntimeFailed))
        try? stateMachine.handle(.reset)
        resetSession()

        do {
            try prepareSession(for: position)
        } catch {
            try? stateMachine.handle(.fail(.mediaServicesResetRecoveryFailed))
        }
    }

    // MARK: Lifecycle

    private var requiresClosing: Bool {
        state != .idle || configuredPosition != nil || isSessionRunning
    }

    private func stopSessionHandlingFailure() throws {
        do {
            try stopSession()
        } catch let error as MediaPickerError {
            try? stateMachine.handle(.fail(error))
            throw error
        }
    }

    // MARK: Session Preparation

    private func resetSession() {
        operations.reset()
        configuredPosition = nil
        lightingCapabilities = .unavailable
        flashMode = .off
        torchMode = .off
    }

    private func prepareSession(for position: CameraPosition) throws {
        try stateMachine.handle(.prepare)

        do {
            try configure(for: position)
            try startSession()
            try stateMachine.handle(.preparationSucceeded)
            refreshLightingCapabilities()
            operations.prepareCameraSwitch(position.opposite)
        } catch let error as MediaPickerError {
            try? stateMachine.handle(.fail(error))
            throw error
        }
    }

    // MARK: Lighting Capabilities

    private func refreshLightingCapabilities() {
        lightingCapabilities = operations.lightingCapabilities()

        if lightingCapabilities.flashModes.contains(flashMode) == false {
            flashMode = .off
        }

        if lightingCapabilities.torchModes.contains(torchMode) == false {
            torchMode = .off
        }
    }

    // MARK: Running State

    private func resumeSession() throws {
        do {
            try startSession()
            try stateMachine.handle(.resume)
        } catch let error as MediaPickerError {
            try? stateMachine.handle(.fail(error))
            throw error
        }
    }

    private func startSession() throws {
        guard isSessionRunning == false else { return }

        do {
            try operations.startRunning()
            isSessionRunning = true
        } catch {
            throw MediaPickerError.captureSessionStartFailed
        }
    }

    private func stopSession() throws {
        guard isSessionRunning else { return }

        do {
            try operations.stopRunning()
            isSessionRunning = false
        } catch {
            throw MediaPickerError.captureSessionStopFailed
        }
    }

}
