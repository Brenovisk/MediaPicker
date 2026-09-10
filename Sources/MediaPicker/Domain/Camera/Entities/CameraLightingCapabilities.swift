//
//  CameraLightingCapabilities.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

struct CameraLightingCapabilities: Sendable, Equatable {

    static let unavailable = CameraLightingCapabilities()

    let flashModes: [CameraFlashMode]
    let torchModes: [CameraTorchMode]

    var supportsFlash: Bool {
        flashModes.isEmpty == false
    }

    var supportsTorch: Bool {
        torchModes.isEmpty == false
    }

    init(
        flashModes: [CameraFlashMode] = [],
        torchModes: [CameraTorchMode] = []
    ) {
        self.flashModes = flashModes
        self.torchModes = torchModes
    }

}
