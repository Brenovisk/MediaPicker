//
//  PhotoCaptureCompletionDelegate.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

@preconcurrency import AVFoundation
import Foundation

/** Collects AVFoundation callbacks and completes their matching request once. */
final class PhotoCaptureCompletionDelegate: NSObject, AVCapturePhotoCaptureDelegate,
    @unchecked Sendable {

    private let lock = NSLock()
    private let processor: PhotoCaptureResultProcessor
    private let onCompletion: @Sendable () -> Void
    private var processedResult: Result<CapturedMedia, any Error>?
    private var continuation: CheckedContinuation<CapturedMedia, any Error>?

    init(
        processor: PhotoCaptureResultProcessor,
        continuation: CheckedContinuation<CapturedMedia, any Error>,
        onCompletion: @escaping @Sendable () -> Void = {}
    ) {
        self.processor = processor
        self.continuation = continuation
        self.onCompletion = onCompletion
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: (any Error)?
    ) {
        let result = Result {
            guard error == nil else { throw MediaPickerError.photoCaptureFailed }
            return try processor.process(
                data: photo.fileDataRepresentation(),
                requestID: photo.resolvedSettings.uniqueID
            )
        }

        lock.withLock {
            if processedResult == nil {
                processedResult = result
            }
        }
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
        error: (any Error)?
    ) {
        let completion = lock.withLock {
            defer {
                self.continuation = nil
                processedResult = nil
            }
            return (self.continuation, processedResult)
        }
        defer { onCompletion() }

        guard let continuation = completion.0 else { return }

        guard error == nil,
              processor.matches(resolvedSettings.uniqueID),
              let result = completion.1 else {
            discardMedia(in: completion.1)
            continuation.resume(throwing: MediaPickerError.photoCaptureFailed)
            return
        }

        switch result {
        case let .success(media):
            continuation.resume(returning: media)
        case .failure:
            continuation.resume(throwing: MediaPickerError.photoCaptureFailed)
        }
    }

    func cancel() {
        let completion = lock.withLock {
            defer {
                continuation = nil
                processedResult = nil
            }
            return (continuation, processedResult)
        }

        guard let continuation = completion.0 else { return }
        discardMedia(in: completion.1)
        continuation.resume(throwing: MediaPickerError.photoCaptureFailed)
        onCompletion()
    }

    private func discardMedia(in result: Result<CapturedMedia, any Error>?) {
        guard case let .success(media) = result else { return }
        processor.discard(media)
    }

}
