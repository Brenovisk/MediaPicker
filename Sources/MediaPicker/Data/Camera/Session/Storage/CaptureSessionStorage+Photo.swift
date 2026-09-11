//
//  CaptureSessionStorage+Photo.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

import AVFoundation

/** Builds compatible settings and waits for AVFoundation to finish the request. */
extension CaptureSessionStorage {

    func capturePhoto(
        flashMode: CameraFlashMode
    ) async throws -> CameraPhotoCaptureRequest {
        guard session.outputs.contains(photoOutput) else {
            throw MediaPickerError.photoCaptureFailed
        }

        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode.captureMode
        let request = CameraPhotoCaptureRequest(id: settings.uniqueID)

        return try await withCheckedThrowingContinuation { continuation in
            let delegate = PhotoCaptureCompletionDelegate(
                request: request,
                continuation: continuation
            )
            photoOutput.capturePhoto(with: settings, delegate: delegate)
        }
    }

}

private extension CameraFlashMode {

    var captureMode: AVCaptureDevice.FlashMode {
        switch self {
        case .off:
            .off
        case .on:
            .on
        case .auto:
            .auto
        }
    }

}
