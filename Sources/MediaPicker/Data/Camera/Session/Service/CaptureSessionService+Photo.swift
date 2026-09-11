//
//  CaptureSessionService+Photo.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

/** Validates and coordinates one asynchronous photo-capture command. */
extension CaptureSessionService {

    func capturePhoto() async throws -> CameraPhotoCaptureRequest {
        guard canCapturePhoto else {
            throw MediaPickerError.photoCaptureFailed
        }

        try stateMachine.handle(.capturePhoto)

        do {
            let request = try await operations.capturePhoto(resolvedFlashMode)
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
