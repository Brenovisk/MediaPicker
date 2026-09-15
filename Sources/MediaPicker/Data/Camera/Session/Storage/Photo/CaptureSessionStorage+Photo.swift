//
//  CaptureSessionStorage+Photo.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

import AVFoundation

/** Builds compatible settings and waits for AVFoundation to finish the request. */
extension CaptureSessionStorage {

    func capturePhoto(options: CameraPhotoCaptureOptions) async throws -> CapturedMedia {
        guard session.outputs.contains(photoOutput),
              photoOutput.availablePhotoCodecTypes.contains(.jpeg) else {
            throw MediaPickerError.photoCaptureFailed
        }

        let settings = AVCapturePhotoSettings(
            format: [AVVideoCodecKey: AVVideoCodecType.jpeg]
        )
        settings.flashMode = options.flashMode.captureMode
        let request = CameraPhotoCaptureRequest(id: settings.uniqueID)
        try configurePhotoConnection(using: options)

        return try await withCheckedThrowingContinuation { continuation in
            let delegate = PhotoCaptureCompletionDelegate(
                processor: PhotoCaptureResultProcessor(
                    request: request,
                    format: options.outputFormat
                ),
                continuation: continuation
            )
            photoOutput.capturePhoto(with: settings, delegate: delegate)
        }
    }

    private func configurePhotoConnection(
        using options: CameraPhotoCaptureOptions
    ) throws {
        guard let connection = photoOutput.connection(with: .video) else {
            throw MediaPickerError.photoCaptureFailed
        }

        let angle = CGFloat(options.rotationAngle)
        guard connection.isVideoRotationAngleSupported(angle) else {
            throw MediaPickerError.photoCaptureFailed
        }
        connection.videoRotationAngle = angle

        guard connection.isVideoMirroringSupported else { return }
        connection.automaticallyAdjustsVideoMirroring = false
        connection.isVideoMirrored = options.isMirrored
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
