//
//  CameraPreviewView.swift
//  MediaPicker
//
//  Created by Breno Lucas on 09/09/26.
//

#if os(iOS)
import AVFoundation
import UIKit

@MainActor
final class CameraPreviewView: UIView {

    // UIKit requires this overridable class property to select the backing layer.
    // swiftlint:disable:next static_over_final_class
    override class var layerClass: AnyClass {
        CameraPreviewLayer.self
    }

    private var previewLayer: CameraPreviewLayer? {
        layer as? CameraPreviewLayer
    }

    init(session: AVCaptureSession) {
        super.init(frame: .zero)
        previewLayer?.session = session
        previewLayer?.videoGravity = .resizeAspectFill
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateVideoOrientation()
    }

    func updateVideoOrientation() {
        guard
            let connection = previewLayer?.connection,
            let orientation = window?.windowScene?.interfaceOrientation
        else { return }

        let angle = CameraPreviewOrientation.rotationAngle(for: orientation)
        guard connection.isVideoRotationAngleSupported(angle) else { return }
        connection.videoRotationAngle = angle
    }

}

private final class CameraPreviewLayer: AVCaptureVideoPreviewLayer {

}
#endif
