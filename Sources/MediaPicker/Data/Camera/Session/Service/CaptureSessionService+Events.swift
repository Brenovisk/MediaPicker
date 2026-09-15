//
//  CaptureSessionService+Events.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

/** Keeps asynchronous session-event handling separate from camera commands. */
extension CaptureSessionService {

    func updates() -> AsyncStream<CameraSessionSnapshot> {
        updateStream
    }

    func handle(_ event: CameraSessionEvent) {
        guard isPickerActive else { return }

        switch event {
        case let .interruptionBegan(reason):
            try? stateMachine.handle(.interruptionBegan(reason))
        case .interruptionEnded:
            guard case .interrupted = state else { return }
            try? stateMachine.handle(.interruptionEnded)
        case .mediaServicesWereReset:
            recoverFromMediaServicesReset()
        case let .runtimeFailure(error):
            isSessionRunning = false
            try? stateMachine.handle(.fail(error))
        }

        publishSnapshot()
    }

    func startObservingEvents() {
        guard isObservingEvents == false else { return }
        isObservingEvents = true
        operations.startObservingEvents { [weak self] event in
            Task { await self?.handle(event) }
        }
    }

    func stopObservingEvents() {
        guard isObservingEvents else { return }
        operations.stopObservingEvents()
        isObservingEvents = false
    }

    private func publishSnapshot() {
        updateContinuation.yield(
            CameraSessionSnapshot(
                state: state,
                position: activeCameraPosition,
                canCapturePhoto: canCapturePhoto,
                lightingCapabilities: lightingCapabilities,
                flashMode: flashMode,
                torchMode: torchMode
            )
        )
    }

}
