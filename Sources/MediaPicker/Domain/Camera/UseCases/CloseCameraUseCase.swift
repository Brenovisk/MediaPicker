//
//  CloseCameraUseCase.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

struct CloseCameraUseCase: Sendable {

    private let cameraSession: any CameraSessionControlling

    init(cameraSession: any CameraSessionControlling) {
        self.cameraSession = cameraSession
    }

    func execute() async throws -> CameraSessionSnapshot {
        try await cameraSession.close()
        return await cameraSession.snapshot()
    }

}
