/**
 Owns and validates camera lifecycle transitions.

 Valid nominal flows are:

 - `idle -> preparing -> ready`
 - `ready -> capturingPhoto -> ready`
 - `ready -> recording -> stoppingRecording -> ready`
 - `preparing|ready|capturingPhoto|recording|stoppingRecording -> failed`
 - `preparing|ready|failed -> idle` through reset
 - `failed -> preparing` to retry preparation

 Events outside these flows are rejected with `CameraStateTransitionError` and
 leave the current state unchanged.
*/
struct CameraStateMachine: Sendable {

    private(set) var state: CameraState = .idle

    mutating func handle(_ event: CameraEvent) throws {
        let nextState = try nextState(for: event)
        state = nextState
    }

    private func nextState(for event: CameraEvent) throws -> CameraState {
        switch (state, event) {
        case (.idle, .prepare), (.failed, .prepare):
            return .preparing
        case (.preparing, .preparationSucceeded):
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
        case (.preparing, .reset), (.ready, .reset), (.failed, .reset):
            return .idle
        case (.preparing, let .fail(error)),
             (.ready, let .fail(error)),
             (.capturingPhoto, let .fail(error)),
             (.recording, let .fail(error)),
             (.stoppingRecording, let .fail(error)):
            return .failed(error)
        default:
            throw CameraStateTransitionError(state: state, event: event)
        }
    }

}
