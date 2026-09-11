//
//  CaptureSessionService+Lifecycle.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

/** Coordinates session preparation, suspension, closing and failure recovery. */
extension CaptureSessionService {

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

    private func prepareSession(for position: CameraPosition) throws {
        try stateMachine.handle(.prepare)

        do {
            try configure(for: position)
            try startSession()
            try stateMachine.handle(.preparationSucceeded)
            refreshCameraCapabilities()
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
