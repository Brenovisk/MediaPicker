//
//  SetCameraTorchModeUseCase.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

struct SetCameraTorchModeUseCase: Sendable {

    private let cameraSession: any CameraSessionControlling

    init(cameraSession: any CameraSessionControlling) {
        self.cameraSession = cameraSession
    }

    func execute(mode: CameraTorchMode) async throws -> CameraSessionSnapshot {
        try await cameraSession.setTorchMode(mode)
        return await cameraSession.snapshot()
    }

}
