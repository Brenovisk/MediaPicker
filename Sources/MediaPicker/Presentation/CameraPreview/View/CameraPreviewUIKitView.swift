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
    private var cameraPosition: CameraPosition = .back
    private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
    private var rotationObservation: NSKeyValueObservation?
    private let frameStore: CameraPreviewFrameStore
    private let imageContext = CIContext(options: [.cacheIntermediates: false])
    private weak var frozenFrame: UIImageView?

    // MARK: Preview Lifecycle

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

    var rotationAngles: CameraRotationAngles {
        guard let rotationCoordinator else { return .zero }

        return CameraRotationAngles(
            preview: rotationCoordinator.videoRotationAngleForHorizonLevelPreview,
            capture: rotationCoordinator.videoRotationAngleForHorizonLevelCapture
        )
    }

    init(session: AVCaptureSession, frameStore: CameraPreviewFrameStore) {
        self.frameStore = frameStore
        super.init(frame: .zero)
        backgroundColor = .black
        previewLayer?.session = session
        previewLayer?.videoGravity = .resizeAspect
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

    // MARK: Camera Position

    func setCameraPosition(_ position: CameraPosition) {
        guard cameraPosition != position || rotationCoordinator == nil else { return }

        cameraPosition = position
        isMirrored = position == .front
        applyMirroring()
        updateVideoOrientation()
    }

    // MARK: Frozen Frame

    @discardableResult
    func freezeCurrentFrame() -> UInt64? {
        guard frozenFrame == nil else { return latestFrameSequence }

        updateVideoOrientation()
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
        snapshot.contentMode = .scaleAspectFit
        snapshot.clipsToBounds = true

        addSubview(snapshot)
        frozenFrame = snapshot

        return frame.sequence
    }

    func releaseFrozenFrame() {
        frozenFrame?.removeFromSuperview()
        frozenFrame = nil
    }

    // MARK: Mirroring

    private func applyMirroring() {
        guard let connection = previewLayer?.connection else { return }
        if connection.automaticallyAdjustsVideoMirroring {
            connection.automaticallyAdjustsVideoMirroring = false
        }
        if connection.isVideoMirrored != isMirrored {
            connection.isVideoMirrored = isMirrored
        }
    }

    // MARK: Orientation

    func updateVideoOrientation() {
        refreshRotationCoordinator()
        applyRotationAngle()
    }

    private var activeCamera: AVCaptureDevice? {
        previewLayer?.session?.inputs
            .compactMap { $0 as? AVCaptureDeviceInput }
            .first?.device
    }

    private func refreshRotationCoordinator() {
        guard let activeCamera,
              rotationCoordinator?.device !== activeCamera else { return }

        observeRotationChanges(for: activeCamera)
    }

    private func observeRotationChanges(for camera: AVCaptureDevice) {
        guard let previewLayer else { return }

        rotationObservation = nil
        let coordinator = AVCaptureDevice.RotationCoordinator(
            device: camera,
            previewLayer: previewLayer
        )
        rotationCoordinator = coordinator
        rotationObservation = coordinator.observe(
            \.videoRotationAngleForHorizonLevelPreview,
            options: [.initial, .new]
        ) { [weak self] _, _ in
            MainActor.assumeIsolated {
                self?.applyRotationAngle()
            }
        }
    }

    private func applyRotationAngle() {
        let angle = CGFloat(rotationAngles.preview)

        guard let connection = previewLayer?.connection,
              rotationCoordinator != nil,
              connection.isVideoRotationAngleSupported(angle),
              connection.videoRotationAngle != angle else { return }

        connection.videoRotationAngle = angle
    }

    private var frozenFrameOrientation: UIImage.Orientation {
        let angle = rotationAngles.preview
        return Self.imageOrientation(rotationAngle: angle, mirrored: isMirrored)
    }

    static func imageOrientation(
        rotationAngle: Double,
        mirrored: Bool
    ) -> UIImage.Orientation {
        switch normalizedQuarterTurn(for: rotationAngle) {
        case 90:
            return mirrored ? .leftMirrored : .right
        case 180:
            return mirrored ? .downMirrored : .down
        case 270:
            return mirrored ? .rightMirrored : .left
        default:
            return mirrored ? .upMirrored : .up
        }
    }

    private static func normalizedQuarterTurn(for angle: Double) -> Int {
        let normalizedAngle = angle.truncatingRemainder(dividingBy: 360)
        let positiveAngle = normalizedAngle < 0
            ? normalizedAngle + 360
            : normalizedAngle
        return Int((positiveAngle / 90).rounded()) * 90 % 360
    }

}

private final class CameraPreviewLayer: AVCaptureVideoPreviewLayer {

}
#endif
