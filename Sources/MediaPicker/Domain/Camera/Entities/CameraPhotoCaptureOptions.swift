//
//  CameraPhotoCaptureOptions.swift
//  MediaPicker
//
//  Created by Breno Lucas on 14/09/26.
//

/** Framework-independent settings resolved for one camera photo capture. */
struct CameraPhotoCaptureOptions: Sendable, Equatable {

    let outputFormat: PhotoOutputFormat
    let flashMode: CameraFlashMode
    let rotationAngle: Double
    let isMirrored: Bool
    /// The visible live viewport; nil keeps the camera's full photo frame.
    let previewFraming: CameraPreviewFraming?

}
