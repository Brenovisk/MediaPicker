//
//  CameraPreviewFrameStore.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

import AVFoundation
import Foundation

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

struct CameraPreviewFrame: @unchecked Sendable {

    let pixelBuffer: CVPixelBuffer
    let sequence: UInt64

}
