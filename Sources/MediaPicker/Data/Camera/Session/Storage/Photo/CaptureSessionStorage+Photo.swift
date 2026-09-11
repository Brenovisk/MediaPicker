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
        flashMode: CameraFlashMode,
        outputFormat: PhotoOutputFormat
    ) async throws -> CapturedMedia {
        guard session.outputs.contains(photoOutput),
              photoOutput.availablePhotoCodecTypes.contains(.jpeg) else {
            throw MediaPickerError.photoCaptureFailed
        }

        let settings = AVCapturePhotoSettings(
            format: [AVVideoCodecKey: AVVideoCodecType.jpeg]
        )
        settings.flashMode = flashMode.captureMode
        let request = CameraPhotoCaptureRequest(id: settings.uniqueID)

        return try await withCheckedThrowingContinuation { continuation in
            let delegate = PhotoCaptureCompletionDelegate(
                processor: PhotoCaptureResultProcessor(
                    request: request,
                    format: outputFormat
                ),
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
