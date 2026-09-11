//
//  CameraRotationAngles.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

/** Rotation angles required to keep camera content aligned with the horizon. */
struct CameraRotationAngles: Sendable, Equatable {

    let preview: Double
    let capture: Double

    static let zero = CameraRotationAngles(preview: 0, capture: 0)

}
