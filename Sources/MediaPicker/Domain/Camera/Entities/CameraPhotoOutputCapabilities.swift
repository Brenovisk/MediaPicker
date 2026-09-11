//
//  CameraPhotoOutputCapabilities.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

/** Capabilities exposed by the photo output configured in the camera session. */
struct CameraPhotoOutputCapabilities: Sendable, Equatable {

    static let unavailable = CameraPhotoOutputCapabilities(
        isAvailable: false,
        flashModes: []
    )

    let isAvailable: Bool
    let flashModes: [CameraFlashMode]

}
