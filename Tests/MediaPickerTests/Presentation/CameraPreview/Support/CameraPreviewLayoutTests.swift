//
//  CameraPreviewLayoutTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 17/09/26.
//

#if os(iOS)
import CoreGraphics
@testable import MediaPicker
import Testing

struct CameraPreviewLayoutTests {

    @Test func portraitIsResolvedFromAvailableSize() {
        let orientation = CameraPreviewOrientation(
            size: CGSize(width: 390, height: 844),
            landscapeSide: .right
        )

        #expect(orientation == .portrait)
        #expect(orientation.controlsLayout == .horizontal)
        #expect(orientation.controlRotationDegrees == .zero)
    }

    @Test func landscapeLeftPlacesVerticalControlsRotatedClockwise() {
        let orientation = CameraPreviewOrientation(
            size: CGSize(width: 844, height: 390),
            landscapeSide: .left
        )

        #expect(orientation == .landscapeLeft)
        #expect(orientation.controlsLayout == .vertical)
        #expect(orientation.controlRotationDegrees == 90)
        #expect(orientation.cancelOnLeadingEdge)
    }

    @Test func landscapeRightPlacesVerticalControlsRotatedCounterclockwise() {
        let orientation = CameraPreviewOrientation(
            size: CGSize(width: 844, height: 390),
            landscapeSide: .right
        )

        #expect(orientation == .landscapeRight)
        #expect(orientation.controlsLayout == .vertical)
        #expect(orientation.controlRotationDegrees == -90)
        #expect(orientation.cancelOnLeadingEdge == false)
    }

}
#endif
