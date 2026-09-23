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
    }

    @Test func landscapeRightPlacesVerticalControlsRotatedCounterclockwise() {
        let orientation = CameraPreviewOrientation(
            size: CGSize(width: 844, height: 390),
            landscapeSide: .right
        )

        #expect(orientation == .landscapeRight)
        #expect(orientation.controlsLayout == .vertical)
        #expect(orientation.controlRotationDegrees == -90)
    }

    @Test func hiddenTopBarReservesNoSpaceInEitherOrientation() {
        let layout = CameraPreviewLayout(orientation: .portrait, showsTopBar: false)

        #expect(layout.reservedTopBarHeight == .zero)
        #expect(layout.reservedTopBarWidth == .zero)
    }

    @Test func landscapeDirectionsUseTheSameControlFrames() {
        let bounds = CGRect(x: 0, y: 0, width: 844, height: 390)
        let leftFrames = CameraPreviewLayout(
            orientation: .landscapeLeft
        ).frames(in: bounds)
        let rightFrames = CameraPreviewLayout(
            orientation: .landscapeRight
        ).frames(in: bounds)

        #expect(leftFrames == rightFrames)
        #expect(leftFrames.topBar.minX == bounds.minX)
        #expect(leftFrames.controls.maxX == bounds.maxX)
        #expect(leftFrames.topBar.maxX == leftFrames.preview.minX)
        #expect(leftFrames.preview.maxX == leftFrames.controls.minX)
    }

    @Test func hiddenTopBarUsesAValidFrameWithoutReducingPreview() {
        let bounds = CGRect(x: 0, y: 0, width: 844, height: 390)
        let frames = CameraPreviewLayout(
            orientation: .landscapeLeft,
            showsTopBar: false
        ).frames(in: bounds)

        #expect(frames.topBar.width > .zero)
        #expect(frames.topBar.height > .zero)
        #expect(frames.topBar.minX > bounds.maxX)
        #expect(frames.preview.minX == bounds.minX)
        #expect(frames.preview.width > .zero)
        #expect(frames.preview.maxX == frames.controls.minX)
    }

    @Test func hidingSelectorMovesShutterDownAndExpandsPreview() {
        let withSelector = CameraPreviewLayout(
            orientation: .portrait,
            showsMediaSelector: true
        )
        let withoutSelector = CameraPreviewLayout(
            orientation: .portrait,
            showsMediaSelector: false
        )

        #expect(withoutSelector.reservedControlsHeight < withSelector.reservedControlsHeight)
        #expect(
            withSelector.reservedControlsHeight
                - withoutSelector.reservedControlsHeight == 80
        )
    }

}
#endif
