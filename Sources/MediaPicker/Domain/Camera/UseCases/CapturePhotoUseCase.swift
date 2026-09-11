//
//  CapturePhotoUseCase.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

/** Starts one photo capture without exposing AVFoundation to presentation. */
struct CapturePhotoUseCase: Sendable {

    private let cameraSession: any CameraSessionControlling

    init(cameraSession: any CameraSessionControlling) {
        self.cameraSession = cameraSession
    }

    func execute() async throws -> CameraPhotoCaptureRequest {
        try await cameraSession.capturePhoto()
    }

}
