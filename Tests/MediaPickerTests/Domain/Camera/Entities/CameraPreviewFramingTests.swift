//
//  CameraPreviewFramingTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 22/09/26.
//

@testable import MediaPicker
import Testing

struct CameraPreviewFramingTests {

    @Test func acceptsAValidVisibleViewport() throws {
        let crop = try #require(
            CameraNormalizedRect(
                originX: 0.1,
                originY: 0.2,
                width: 0.8,
                height: 0.6
            )
        )
        let framing = CameraPreviewFraming(
            aspectRatio: 4.0 / 3.0,
            normalizedCrop: crop
        )

        #expect(framing?.normalizedCrop == crop)
    }

    @Test func rejectsInvalidViewportValues() {
        #expect(
            CameraNormalizedRect(
                originX: -0.1,
                originY: 0,
                width: 1,
                height: 1
            ) == nil
        )
        #expect(
            CameraNormalizedRect(
                originX: 0.5,
                originY: 0,
                width: 0.6,
                height: 1
            ) == nil
        )
        #expect(CameraPreviewFraming(aspectRatio: .zero) == nil)
    }

}
