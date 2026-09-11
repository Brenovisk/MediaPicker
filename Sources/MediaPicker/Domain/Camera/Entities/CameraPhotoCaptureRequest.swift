//
//  CameraPhotoCaptureRequest.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

/** Identifies one photo request across the asynchronous capture pipeline. */
struct CameraPhotoCaptureRequest: Sendable, Equatable, Hashable {

    let id: Int64

}
