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

    func execute(
        format: PhotoOutputFormat,
        rotationAngle: Double,
        previewFraming: CameraPreviewFraming? = nil
    ) async throws -> CapturedMedia {
        try await cameraSession.capturePhoto(
            format: format,
            rotationAngle: rotationAngle,
            previewFraming: previewFraming
        )
    }

}
