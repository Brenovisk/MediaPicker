//
//  CameraPreviewFrameStore.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

import AVFoundation
import Foundation

/**
 Keeps the most recent video frame produced by the capture session.

 `CaptureSessionStorage` registers this object as the delegate of an
 `AVCaptureVideoDataOutput`. Each callback replaces the previous pixel buffer
 instead of accumulating frames, keeping memory usage bounded.

 The latest frame is used for two purposes during a camera switch: presenting a
 frozen image while the hardware changes and confirming that the new camera has
 produced a frame. The monotonically increasing sequence distinguishes a new
 frame from the one captured before the switch.

 Sample-buffer callbacks run on the dedicated frame queue while the preview
 reads from the Main Actor. `NSLock` protects both stored values across those
 execution contexts. The type is `@unchecked Sendable` because AVFoundation's
 delegate API is not modeled with Swift concurrency; thread safety is provided
 explicitly by that lock.
*/
final class CameraPreviewFrameStore: NSObject, @unchecked Sendable {

    private let lock = NSLock()
    private var pixelBuffer: CVPixelBuffer?
    private var sequence = UInt64.zero

    var latestFrame: CameraPreviewFrame? {
        lock.withLock {
            guard let pixelBuffer else { return nil }
            return CameraPreviewFrame(pixelBuffer: pixelBuffer, sequence: sequence)
        }
    }

}

extension CameraPreviewFrameStore: AVCaptureVideoDataOutputSampleBufferDelegate {

    /// Retains the newest valid pixel buffer and advances its sequence number.
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        lock.withLock {
            self.pixelBuffer = pixelBuffer
            sequence &+= 1
        }
    }

}

/**
 Immutable frame snapshot shared with the preview transition.

 `CVPixelBuffer` does not declare `Sendable`, so this wrapper uses unchecked
 conformance. The store only publishes a retained buffer after AVFoundation has
 delivered it and consumers treat it as read-only.
*/
struct CameraPreviewFrame: @unchecked Sendable {

    let pixelBuffer: CVPixelBuffer
    let sequence: UInt64

}
