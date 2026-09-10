//
//  OpenCameraUseCase.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

struct OpenCameraUseCase: Sendable {

    private let cameraSession: any CameraSessionControlling

    init(cameraSession: any CameraSessionControlling) {
        self.cameraSession = cameraSession
    }

    func execute(position: CameraPosition) async throws -> CameraSessionSnapshot {
        try await cameraSession.open(for: position)
        return await cameraSession.snapshot()
    }

}
