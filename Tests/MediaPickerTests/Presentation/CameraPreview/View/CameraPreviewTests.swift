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

        view.setMirroring(true)
        #expect(view.isMirrored)

        view.setMirroring(false)
        #expect(view.isMirrored == false)
    }

    @Test(arguments: [
        (UIInterfaceOrientation.portrait, CGFloat(90)),
        (.portraitUpsideDown, CGFloat(270)),
        (.landscapeLeft, CGFloat(0)),
        (.landscapeRight, CGFloat(180)),
        (.unknown, CGFloat(90))
    ])
    func orientationMapsToPredictableRotationAngle(
        orientation: UIInterfaceOrientation,
        angle: CGFloat
    ) {
        #expect(CameraPreviewOrientation.rotationAngle(for: orientation) == angle)
    }

}
#endif
