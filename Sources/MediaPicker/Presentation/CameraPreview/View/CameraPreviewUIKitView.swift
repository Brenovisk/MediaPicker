//
//  CameraPreviewUIKitView.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

#if os(iOS)
import AVFoundation
import CoreImage
import UIKit

@MainActor
final class CameraPreviewUIKitView: UIView {

    private(set) var isMirrored = false
    private let frameStore: CameraPreviewFrameStore
    private let imageContext = CIContext(options: [.cacheIntermediates: false])
    private weak var frozenFrame: UIImageView?

    // UIKit requires this overridable class property to select the backing layer.
    // swiftlint:disable:next static_over_final_class
    override class var layerClass: AnyClass {
        CameraPreviewLayer.self
    }

    private var previewLayer: CameraPreviewLayer? {
        layer as? CameraPreviewLayer
    }

    var latestFrameSequence: UInt64? {
        frameStore.latestFrame?.sequence
    }

    init(session: AVCaptureSession, frameStore: CameraPreviewFrameStore) {
        self.frameStore = frameStore
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
        applyMirroring()
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

    func setMirroring(_ isMirrored: Bool) {
        self.isMirrored = isMirrored
        applyMirroring()
    }

    @discardableResult
    func freezeCurrentFrame() -> UInt64? {
        guard frozenFrame == nil else { return latestFrameSequence }

        guard let frame = frameStore.latestFrame else { return nil }
        let sourceImage = CIImage(cvPixelBuffer: frame.pixelBuffer)

        guard let image = imageContext.createCGImage(
            sourceImage,
            from: sourceImage.extent
        ) else { return nil }

        let snapshot = UIImageView(
            image: UIImage(
                cgImage: image,
                scale: 1,
                orientation: frozenFrameOrientation
            )
        )

        snapshot.frame = bounds
        snapshot.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        snapshot.contentMode = .scaleAspectFill
        snapshot.clipsToBounds = true

        addSubview(snapshot)
        frozenFrame = snapshot

        return frame.sequence
    }

    func releaseFrozenFrame() {
        frozenFrame?.removeFromSuperview()
        frozenFrame = nil
    }

    private func applyMirroring() {
        guard let connection = previewLayer?.connection else { return }
        connection.automaticallyAdjustsVideoMirroring = false
        connection.isVideoMirrored = isMirrored
    }

    private var frozenFrameOrientation: UIImage.Orientation {
        switch window?.windowScene?.interfaceOrientation {
        case .landscapeLeft:
            isMirrored ? .downMirrored : .up
        case .landscapeRight:
            isMirrored ? .upMirrored : .down
        case .portraitUpsideDown:
            isMirrored ? .rightMirrored : .left
        case .portrait, .unknown, nil:
            isMirrored ? .leftMirrored : .right
        @unknown default:
            isMirrored ? .leftMirrored : .right
        }
    }

}

private final class CameraPreviewLayer: AVCaptureVideoPreviewLayer {

}
#endif
