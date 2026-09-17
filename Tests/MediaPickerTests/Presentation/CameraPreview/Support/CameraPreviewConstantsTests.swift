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
                == "arrow.triangle.2.circlepath"
        )
    }

    @Test func controlIconsReflectTheirActionsAndFlashModes() {
        #expect(CameraPreviewConstants.Icon.close.systemName == "xmark")
        #expect(CameraPreviewConstants.Icon.confirmPhoto.systemName == "checkmark")
        #expect(CameraPreviewConstants.Icon.flash(.off).systemName == "bolt.slash.fill")
        #expect(CameraPreviewConstants.Icon.flash(.on).systemName == "bolt.fill")
        #expect(
            CameraPreviewConstants.Icon.flash(.auto).systemName
                == "bolt.badge.automatic.fill"
        )
        if #available(iOS 18.0, *) {
            #expect(
                CameraPreviewConstants.Icon.retakePhoto.systemName
                    == "arrow.trianglehead.2.clockwise.rotate.90.camera"
            )
        }
    }

    @Test func everyControlMeetsTheMinimumTapTarget() {
        #expect(
            CameraPreviewConstants.Layout.controlSize
                >= CameraPreviewConstants.Layout.minimumTapTarget
        )
        #expect(
            CameraPreviewConstants.Layout.shutterSize
                >= CameraPreviewConstants.Layout.minimumTapTarget
        )
    }

}
#endif
