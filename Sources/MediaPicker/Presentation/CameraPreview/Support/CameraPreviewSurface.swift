//
//  CameraPreviewSurface.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

#if os(iOS)
import Foundation

@MainActor
final class CameraPreviewSurface {

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
