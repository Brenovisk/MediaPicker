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
actor CaptureSessionService {

    nonisolated private let executor: DispatchSerialQueue
    nonisolated let previewSession: CaptureSessionReference?
    private let operations: CaptureSessionOperations
    private var stateMachine = CameraStateMachine()
    private var configuredPosition: CameraPosition?
    private var isPickerActive = false
    private var isSessionRunning = false

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
        executor = DispatchSerialQueue(
            label: MediaPickerInfrastructureConstants.captureSessionQueueLabel
        )
        previewSession = operations.previewSession
        self.operations = operations
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

        switch state {
        case .ready:
            return
        case .suspended:
            try resumeSession()
        case .idle, .failed:
            try prepareSession(for: position)
        case .preparing, .capturingPhoto, .recording, .stoppingRecording:
            throw CameraStateTransitionError(state: state, event: .prepare)
        }
    }

    func close() throws {
        isPickerActive = false

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
            return newPosition
        } catch let error as MediaPickerError {
            throw error
        } catch {
            throw MediaPickerError.captureSessionSwitchFailed
        }
    }

}

// MARK: Helper Methods
extension CaptureSessionService {

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

    private func resetSession() {
        operations.reset()
        configuredPosition = nil
    }

    private func prepareSession(for position: CameraPosition) throws {
        try stateMachine.handle(.prepare)

        do {
            try configure(for: position)
            try startSession()
            try stateMachine.handle(.preparationSucceeded)
            operations.prepareCameraSwitch(position.opposite)
        } catch let error as MediaPickerError {
            try? stateMachine.handle(.fail(error))
            throw error
        }
    }

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
