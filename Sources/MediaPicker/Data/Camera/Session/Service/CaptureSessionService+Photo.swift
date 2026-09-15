//
//  CaptureSessionService+Photo.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

/**
 Validates and coordinates one asynchronous photo-capture command.

 Front-camera photos are intentionally mirrored to match the preview users see;
 back-camera photos remain unmirrored. The current capture rotation is supplied
 by presentation immediately before the request starts.
*/
extension CaptureSessionService {

    func capturePhoto(
        format: PhotoOutputFormat,
        rotationAngle: Double
    ) async throws -> CapturedMedia {
        guard canCapturePhoto else {
            throw MediaPickerError.photoCaptureFailed
        }

        try stateMachine.handle(.capturePhoto)

        do {
            let request = try await operations.capturePhoto(
                CameraPhotoCaptureOptions(
                    outputFormat: format,
                    flashMode: resolvedFlashMode,
                    rotationAngle: rotationAngle,
                    isMirrored: configuredPosition == .front
                )
            )
            try stateMachine.handle(.photoCaptured)
            return request
        } catch {
            try? stateMachine.handle(.photoCaptured)
            throw MediaPickerError.photoCaptureFailed
        }
    }

    private var resolvedFlashMode: CameraFlashMode {
        let deviceSupportsMode = lightingCapabilities.flashModes.contains(flashMode)
        let outputSupportsMode = photoOutputCapabilities.flashModes.contains(flashMode)
        return deviceSupportsMode && outputSupportsMode ? flashMode : .off
    }

}
