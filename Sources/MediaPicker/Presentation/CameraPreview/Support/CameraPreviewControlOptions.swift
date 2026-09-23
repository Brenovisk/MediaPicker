//
//  CameraPreviewControlOptions.swift
//  MediaPicker
//
//  Created by Breno Lucas on 18/09/26.
//

#if os(iOS)
import SwiftUI

/**
 Appearance and independently available actions for the live camera controls.

 `mediaTypes` defaults to photo because video recording has not been implemented.
 If both types are enabled, the selector is shown, but the video shutter remains
 unavailable until recording support is added.
*/
public struct CameraPreviewControlOptions {

    public let mediaTypes: MediaType
    public let foregroundColor: Color
    public let backgroundColor: Color
    public let showsFlash: Bool
    public let showsSwitchCamera: Bool
    public let showsGallery: Bool
    public let showsReview: Bool

    public init(
        mediaTypes: MediaType = .photo,
        foregroundColor: Color = .white,
        backgroundColor: Color = .black,
        showsFlash: Bool = true,
        showsSwitchCamera: Bool = true,
        showsGallery: Bool = true,
        showsReview: Bool = true
    ) {
        self.mediaTypes = mediaTypes
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.showsFlash = showsFlash
        self.showsSwitchCamera = showsSwitchCamera
        self.showsGallery = showsGallery
        self.showsReview = showsReview
    }

    var showsMediaSelector: Bool {
        mediaTypes.contains(.photo) && mediaTypes.contains(.video)
    }

    var initialMediaType: MediaType {
        mediaTypes.contains(.photo) ? .photo : .video
    }

    func canCapturePhoto(in selection: MediaType) -> Bool {
        mediaTypes.contains(.photo) && selection == .photo
    }

    var canChoosePhotoFromGallery: Bool {
        showsGallery && mediaTypes.contains(.photo)
    }

}
#endif
