@testable import MediaPicker
import Testing

struct CameraStateMachineTests {

    @Test func initialStateIsIdle() {
        let stateMachine = CameraStateMachine()

        #expect(stateMachine.state == .idle)
    }

    @Test func preparationMovesCameraFromIdleToReady() throws {
        var stateMachine = CameraStateMachine()

        try stateMachine.handle(.prepare)
        #expect(stateMachine.state == .preparing)

        try stateMachine.handle(.preparationSucceeded)
        #expect(stateMachine.state == .ready)
    }

    @Test func photoCaptureReturnsCameraToReady() throws {
        var stateMachine = try readyStateMachine()

        try stateMachine.handle(.capturePhoto)
        #expect(stateMachine.state == .capturingPhoto)

        try stateMachine.handle(.photoCaptured)
        #expect(stateMachine.state == .ready)
    }

    @Test func suspendedCameraCanResumeToReady() throws {
        var stateMachine = try readyStateMachine()

        try stateMachine.handle(.suspend)
        #expect(stateMachine.state == .suspended)

        try stateMachine.handle(.resume)
        #expect(stateMachine.state == .ready)
    }

    @Test func recordingStopsBeforeReturningCameraToReady() throws {
        var stateMachine = try readyStateMachine()

        try stateMachine.handle(.startRecording)
        #expect(stateMachine.state == .recording)

        try stateMachine.handle(.stopRecording)
        #expect(stateMachine.state == .stoppingRecording)

        try stateMachine.handle(.recordingStopped)
        #expect(stateMachine.state == .ready)
    }

    @Test func failurePreservesErrorForPresentation() throws {
        var stateMachine = CameraStateMachine()
        try stateMachine.handle(.prepare)

        try stateMachine.handle(.fail(.sourceUnavailable(.camera)))

        #expect(stateMachine.state == .failed(.sourceUnavailable(.camera)))
    }

    @Test func failedCameraCanRetryPreparation() throws {
        var stateMachine = CameraStateMachine()
        try stateMachine.handle(.prepare)
        try stateMachine.handle(.fail(.photoCaptureFailed))

        try stateMachine.handle(.prepare)

        #expect(stateMachine.state == .preparing)
    }

    @Test func resetReturnsPreparedOrFailedCameraToIdle() throws {
        var readyCamera = try readyStateMachine()
        try readyCamera.handle(.reset)

        var failedCamera = CameraStateMachine()
        try failedCamera.handle(.prepare)
        try failedCamera.handle(.fail(.unknown))
        try failedCamera.handle(.reset)

        #expect(readyCamera.state == .idle)
        #expect(failedCamera.state == .idle)
    }

    @Test func incompatibleEventIsRejectedWithoutChangingState() {
        var stateMachine = CameraStateMachine()

        #expect(throws: CameraStateTransitionError(
            state: .idle,
            event: .capturePhoto
        )) {
            try stateMachine.handle(.capturePhoto)
        }
        #expect(stateMachine.state == .idle)
    }

    @Test func cameraStateTypesAreSendable() {
        requireSendable(CameraState.idle)
        requireSendable(CameraEvent.prepare)
        requireSendable(CameraStateMachine())
    }

}

private extension CameraStateMachineTests {

    func readyStateMachine() throws -> CameraStateMachine {
        var stateMachine = CameraStateMachine()
        try stateMachine.handle(.prepare)
        try stateMachine.handle(.preparationSucceeded)
        return stateMachine
    }

    func requireSendable<T: Sendable>(_: T) {}

}
