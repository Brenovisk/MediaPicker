//
//  CameraPreviewConstantsTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

#if os(iOS)
@testable import MediaPicker
import SwiftUI
import Testing

struct CameraPreviewConstantsTests {

    @Test func switchCameraIconProvidesItsSystemName() {
        #expect(
            CameraPreviewConstants.Icon.switchCamera.systemName
                == "arrow.triangle.2.circlepath.camera"
        )
    }

    @Test func switchCameraIconProvidesAnImage() {
        let image: Image = CameraPreviewConstants.Icon.switchCamera.image
        _ = image
    }

    @Test func switchCameraIconProvidesItsStandardStyle() {
        let styledImage = CameraPreviewConstants.Icon.switchCamera.styledImage
        _ = styledImage
    }

}
#endif
