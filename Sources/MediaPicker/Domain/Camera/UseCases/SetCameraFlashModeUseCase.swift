//
//  SetCameraFlashModeUseCase.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

struct SetCameraFlashModeUseCase: Sendable {

    private let cameraSession: any CameraSessionControlling

    init(cameraSession: any CameraSessionControlling) {
        self.cameraSession = cameraSession
    }

    func execute(mode: CameraFlashMode) async throws -> CameraSessionSnapshot {
        try await cameraSession.setFlashMode(mode)
        return await cameraSession.snapshot()
    }

}
