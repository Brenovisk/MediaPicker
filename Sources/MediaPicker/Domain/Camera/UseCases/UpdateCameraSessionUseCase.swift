//
//  UpdateCameraSessionUseCase.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

struct UpdateCameraSessionUseCase: Sendable {

    private let cameraSession: any CameraSessionControlling

    init(cameraSession: any CameraSessionControlling) {
        self.cameraSession = cameraSession
    }

    func execute(
        event: CameraSessionLifecycleEvent
    ) async throws -> CameraSessionSnapshot {
        switch event {
        case .enteredForeground:
            try await cameraSession.applicationWillEnterForeground()
        case .enteredBackground:
            try await cameraSession.applicationDidEnterBackground()
        }

        return await cameraSession.snapshot()
    }

    func observe() async -> AsyncStream<CameraSessionSnapshot> {
        await cameraSession.updates()
    }

}
