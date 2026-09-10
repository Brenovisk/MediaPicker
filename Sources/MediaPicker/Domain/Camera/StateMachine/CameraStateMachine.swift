/**
 Owns and validates camera lifecycle transitions.

 Valid nominal flows are:

 - `idle -> preparing -> ready`
 - `ready -> suspended -> ready` while the app backgrounds and foregrounds
 - `ready -> capturingPhoto -> ready`
 - `ready -> recording -> stoppingRecording -> ready`
 - `preparing|ready|capturingPhoto|recording|stoppingRecording -> failed`
 - `preparing|ready|suspended|failed -> idle` through reset
 - `failed -> preparing` to retry preparation

 Events outside these flows are rejected with `CameraStateTransitionError` and
 leave the current state unchanged.
*/
struct CameraStateMachine: Sendable {

    private(set) var state: CameraState = .idle

    mutating func handle(_ event: CameraEvent) throws {
        let nextState: CameraState

        switch event {
        case let .fail(error):
            nextState = try failedState(for: error, event: event)
        case .reset:
            nextState = try resetState(for: event)
        default:
            nextState = try nominalState(for: event)
        }

        state = nextState
    }

    private func nominalState(for event: CameraEvent) throws -> CameraState {
        switch (state, event) {
        case (.idle, .prepare), (.failed, .prepare):
            return .preparing
        case (.preparing, .preparationSucceeded):
            return .ready
        case (.ready, .suspend):
            return .suspended
        case (.suspended, .resume):
            return .ready
        case (.ready, .capturePhoto):
            return .capturingPhoto
        case (.capturingPhoto, .photoCaptured):
            return .ready
        case (.ready, .startRecording):
            return .recording
        case (.recording, .stopRecording):
            return .stoppingRecording
        case (.stoppingRecording, .recordingStopped):
            return .ready
        default:
            throw CameraStateTransitionError(state: state, event: event)
        }
    }

    private func failedState(
        for error: MediaPickerError,
        event: CameraEvent
    ) throws -> CameraState {
        switch state {
        case .preparing, .ready, .suspended, .capturingPhoto, .recording, .stoppingRecording:
            return .failed(error)
        case .idle, .failed:
            throw CameraStateTransitionError(state: state, event: event)
        }
    }

    private func resetState(for event: CameraEvent) throws -> CameraState {
        switch state {
        case .preparing, .ready, .suspended, .failed:
            return .idle
        case .idle, .capturingPhoto, .recording, .stoppingRecording:
            throw CameraStateTransitionError(state: state, event: event)
        }
    }

}
