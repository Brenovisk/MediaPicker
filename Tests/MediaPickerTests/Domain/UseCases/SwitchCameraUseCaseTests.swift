//
//  SwitchCameraUseCaseTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

#if os(iOS)
@testable import MediaPicker
import Testing

@MainActor
struct SwitchCameraUseCaseTests {

    @Test func returnsNewPositionAfterPreviewBecomesReady() async throws {
        let cameraSwitcher = CameraSwitcherSpy(positions: [.front])
        let frameReadiness = CameraFrameReadinessSpy(
            latestFrameSequence: 7,
            readinessResults: [true]
        )
        let useCase = SwitchCameraUseCase(
            cameraSession: cameraSwitcher,
            frameReadiness: frameReadiness
        )

        let position = try await useCase.execute()

        #expect(position == .front)
        #expect(frameReadiness.requestedSequences == [7])
        #expect(await cameraSwitcher.switchCount == 1)
    }

    @Test func restoresPreviousCameraWhenNewPreviewTimesOut() async {
        let cameraSwitcher = CameraSwitcherSpy(positions: [.front, .back])
        let frameReadiness = CameraFrameReadinessSpy(
            latestFrameSequence: 11,
            readinessResults: [false, true]
        )
        let useCase = SwitchCameraUseCase(
            cameraSession: cameraSwitcher,
            frameReadiness: frameReadiness
        )

        await #expect(throws: MediaPickerError.captureSessionSwitchFailed) {
            try await useCase.execute()
        }
        #expect(frameReadiness.requestedSequences == [11, nil])
        #expect(await cameraSwitcher.switchCount == 2)
    }

}

#endif
