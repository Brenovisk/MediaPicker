//
//  CameraPreviewControlOptionsTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 18/09/26.
//

#if os(iOS)
@testable import MediaPicker
import SwiftUI
import Testing

struct CameraPreviewControlOptionsTests {

    @Test func defaultOptionsKeepAvailablePhotoActionsVisible() {
        let options = CameraPreviewControlOptions()

        #expect(options.mediaTypes == .photo)
        #expect(options.showsFlash)
        #expect(options.showsSwitchCamera)
        #expect(options.showsGallery)
        #expect(options.showsReview)
        #expect(options.canChoosePhotoFromGallery)
    }

    @Test func selectorOnlyAppearsWithBothMediaTypes() {
        #expect(CameraPreviewControlOptions().showsMediaSelector == false)
        #expect(
            CameraPreviewControlOptions(mediaTypes: .photoAndVideo).showsMediaSelector
        )
        #expect(CameraPreviewControlOptions(mediaTypes: .video).showsMediaSelector == false)
    }

    @Test func selectedModeOnlyEnablesImplementedPhotoCapture() {
        let options = CameraPreviewControlOptions(mediaTypes: .photoAndVideo)

        #expect(options.initialMediaType == .photo)
        #expect(options.canCapturePhoto(in: .photo))
        #expect(options.canCapturePhoto(in: .video) == false)
        #expect(CameraPreviewControlOptions(mediaTypes: .video).initialMediaType == .video)
    }

    @Test func controlsCanBeHiddenIndependentlyWithoutSuppressingOthers() {
        let options = CameraPreviewControlOptions(
            mediaTypes: .photo,
            showsFlash: false,
            showsSwitchCamera: false,
            showsGallery: false,
            showsReview: false
        )

        #expect(options.showsFlash == false)
        #expect(options.showsSwitchCamera == false)
        #expect(options.canChoosePhotoFromGallery == false)
        #expect(options.showsReview == false)
        #expect(options.canCapturePhoto(in: .photo))
        #expect(CameraPreviewControlOptions().canChoosePhotoFromGallery)
    }

    @Test func customControlColorsArePreserved() {
        let options = CameraPreviewControlOptions(
            foregroundColor: .yellow,
            backgroundColor: .blue
        )

        #expect(options.foregroundColor == .yellow)
        #expect(options.backgroundColor == .blue)
    }

}
#endif
