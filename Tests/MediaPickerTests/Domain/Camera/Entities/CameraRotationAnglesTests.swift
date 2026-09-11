//
//  CameraRotationAnglesTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

@testable import MediaPicker
import Testing

struct CameraRotationAnglesTests {

    @Test func storesPreviewAndCaptureAnglesIndependently() {
        let angles = CameraRotationAngles(preview: 90, capture: 180)

        #expect(angles.preview == 90)
        #expect(angles.capture == 180)
        requireSendable(angles)
    }

    private func requireSendable<T: Sendable>(_: T) {}

}
