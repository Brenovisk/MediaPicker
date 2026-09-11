//
//  PhotoCaptureCompletionDelegate.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

@preconcurrency import AVFoundation
import Foundation

/** Completes a photo request once when AVFoundation reports its final status. */
final class PhotoCaptureCompletionDelegate: NSObject, AVCapturePhotoCaptureDelegate,
    @unchecked Sendable {

    private let lock = NSLock()
    private let request: CameraPhotoCaptureRequest
    private var continuation: CheckedContinuation<CameraPhotoCaptureRequest, any Error>?

    init(
        request: CameraPhotoCaptureRequest,
        continuation: CheckedContinuation<CameraPhotoCaptureRequest, any Error>
    ) {
        self.request = request
        self.continuation = continuation
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
        error: (any Error)?
    ) {
        let continuation = lock.withLock {
            defer { self.continuation = nil }
            return self.continuation
        }

        guard let continuation else { return }

        if error == nil {
            continuation.resume(returning: request)
        } else {
            continuation.resume(throwing: MediaPickerError.photoCaptureFailed)
        }
    }

}
