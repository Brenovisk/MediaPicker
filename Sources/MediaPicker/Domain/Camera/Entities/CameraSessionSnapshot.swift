//
//  CameraSessionSnapshot.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

struct CameraSessionSnapshot: Sendable {

    let state: CameraState
    let position: CameraPosition?
    let canCapturePhoto: Bool
    let lightingCapabilities: CameraLightingCapabilities
    let flashMode: CameraFlashMode
    let torchMode: CameraTorchMode

}
