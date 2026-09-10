//
//  SwitchCameraUseCase.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

#if os(iOS)
@MainActor
final class SwitchCameraUseCase {

    private let cameraSession: any CameraSessionControlling
    private let frameReadiness: any CameraFrameReadinessProviding

    init(
        cameraSession: any CameraSessionControlling,
        frameReadiness: any CameraFrameReadinessProviding
    ) {
        self.cameraSession = cameraSession
        self.frameReadiness = frameReadiness
    }

    func execute() async throws -> CameraSessionSnapshot {
        _ = try await cameraSession.switchCamera()
        let sequenceAfterSwitch = frameReadiness.latestFrameSequence
        let isPreviewReady = await frameReadiness.waitForFrame(
            after: sequenceAfterSwitch
        )

        guard isPreviewReady else {
            try await restorePreviousCamera()
            throw MediaPickerError.captureSessionSwitchFailed
        }

        return await cameraSession.snapshot()
    }

    private func restorePreviousCamera() async throws {
        _ = try await cameraSession.switchCamera()
        _ = await frameReadiness.waitForFrame(after: nil)
    }

}
#endif
