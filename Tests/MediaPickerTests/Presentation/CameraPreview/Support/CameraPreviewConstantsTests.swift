//
//  CameraPreviewConstantsTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

#if os(iOS)
@testable import MediaPicker
import Testing

struct CameraPreviewConstantsTests {

    @Test func switchCameraIconProvidesItsSystemName() {
        #expect(
            CameraPreviewConstants.Icon.switchCamera.systemName
                == "arrow.triangle.2.circlepath.camera"
        )
    }

}
#endif
