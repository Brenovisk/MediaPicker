//
//  CameraPreviewTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 09/09/26.
//

#if os(iOS)
import AVFoundation
@testable import MediaPicker
import Testing
import UIKit

@MainActor
struct CameraPreviewTests {

    @Test func previewUsesProvidedSessionAndAspectFill() {
        let session = AVCaptureSession()
        let view = CameraPreviewUIKitView(
            session: session,
            frameStore: CameraPreviewFrameStore()
        )
        let previewLayer = view.layer as? AVCaptureVideoPreviewLayer

        #expect(previewLayer?.session === session)
        #expect(previewLayer?.videoGravity == .resizeAspectFill)
    }

    @Test func previewLayerFollowsViewSizeChanges() {
        let view = CameraPreviewUIKitView(
            session: AVCaptureSession(),
            frameStore: CameraPreviewFrameStore()
        )

        view.frame = CGRect(x: 0, y: 0, width: 320, height: 640)
        view.layoutIfNeeded()

        #expect(view.layer.bounds == view.bounds)
    }

    @Test func updatingPreviewDoesNotReplaceSessionOrLayer() {
        let session = AVCaptureSession()
        let view = CameraPreviewUIKitView(
            session: session,
            frameStore: CameraPreviewFrameStore()
        )
        let originalLayer = view.layer

        view.updateVideoOrientation()

        #expect(view.layer === originalLayer)
        #expect((view.layer as? AVCaptureVideoPreviewLayer)?.session === session)
    }

    @Test func frontCameraMirroringIsExplicitAndReversible() {
        let view = CameraPreviewUIKitView(
            session: AVCaptureSession(),
            frameStore: CameraPreviewFrameStore()
        )

        view.setCameraPosition(.front)
        #expect(view.isMirrored)

        view.setCameraPosition(.back)
        #expect(view.isMirrored == false)
    }

    @Test(arguments: [
        (Double(0), false, UIImage.Orientation.up),
        (Double(90), false, .right),
        (Double(180), false, .down),
        (Double(270), false, .left),
        (Double(0), true, .upMirrored),
        (Double(90), true, .leftMirrored),
        (Double(180), true, .downMirrored),
        (Double(270), true, .rightMirrored)
    ])
    func frozenFrameMatchesPreviewOrientation(
        angle: Double,
        mirrored: Bool,
        expected: UIImage.Orientation
    ) {
        let orientation = CameraPreviewUIKitView.imageOrientation(
            rotationAngle: angle,
            mirrored: mirrored
        )

        #expect(orientation == expected)
    }

}
#endif
