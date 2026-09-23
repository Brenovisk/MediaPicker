//
//  CameraPreviewSurface.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

#if os(iOS)
import Foundation

/**
 Bridges camera-switching logic to the UIKit preview without exposing the view
 outside the Presentation layer.

 It keeps a weak reference to the active preview, freezes and releases the
 displayed frame during transitions, and confirms readiness by waiting for a
 frame sequence newer than the one produced before the camera switch.
*/
@MainActor
final class CameraPreviewSurface: CameraFrameReadinessProviding {

    private weak var previewView: CameraPreviewUIKitView?

    func attach(_ previewView: CameraPreviewUIKitView) {
        self.previewView = previewView
    }

    func detach(_ previewView: CameraPreviewUIKitView) {
        guard self.previewView === previewView else { return }
        self.previewView = nil
    }

    func freezeCurrentFrame() {
        _ = previewView?.freezeCurrentFrame()
    }

    func releaseFrozenFrame() {
        previewView?.releaseFrozenFrame()
    }

    var latestFrameSequence: UInt64? {
        previewView?.latestFrameSequence
    }

    /** Current preview and capture angles without exposing AVFoundation. */
    var rotationAngles: CameraRotationAngles {
        previewView?.rotationAngles ?? .zero
    }

    /** Exact visible viewport used to make the saved photo match the preview. */
    var captureFraming: CameraPreviewFraming? {
        previewView?.captureFraming
    }

    var captureAspectRatio: Double? {
        captureFraming?.aspectRatio
    }

    func waitForFrame(after sequence: UInt64?) async -> Bool {
        guard let previewView else { return true }

        let clock = ContinuousClock()
        let deadline = clock.now.advanced(
            by: .seconds(CameraPreviewConstants.Motion.previewReadinessTimeout)
        )

        while clock.now < deadline {
            if let currentSequence = previewView.latestFrameSequence {
                guard let sequence else { return true }

                if currentSequence > sequence {
                    return true
                }
            }

            try? await Task.sleep(
                for: .seconds(CameraPreviewConstants.Motion.readinessPollingInterval)
            )
        }

        return false
    }

}
#endif
