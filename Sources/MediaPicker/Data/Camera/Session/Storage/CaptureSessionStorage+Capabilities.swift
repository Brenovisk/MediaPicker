//
//  CaptureSessionStorage+Capabilities.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

import AVFoundation

/** Reads photo and lighting capabilities and applies the selected torch mode. */
extension CaptureSessionStorage {

    func lightingCapabilities() -> CameraLightingCapabilities {
        guard let device = videoInput?.device else { return .unavailable }

        let flashModes: [CameraFlashMode] = device.hasFlash ? CameraFlashMode.allCases : []
        let torchModes = device.hasTorch
            ? CameraTorchMode.allCases.filter {
                device.isTorchModeSupported($0.captureMode)
            }
            : []

        return CameraLightingCapabilities(
            flashModes: flashModes,
            torchModes: torchModes
        )
    }

    func photoOutputCapabilities() -> CameraPhotoOutputCapabilities {
        guard session.outputs.contains(photoOutput) else { return .unavailable }

        return CameraPhotoOutputCapabilities(
            isAvailable: true,
            flashModes: photoOutput.supportedFlashModes.compactMap(\.cameraFlashMode)
        )
    }

    func setTorchMode(_ mode: CameraTorchMode) throws {
        guard let device = videoInput?.device,
              device.isTorchModeSupported(mode.captureMode) else {
            throw CaptureSessionConfigurationError.unsupportedTorchMode
        }

        try device.lockForConfiguration()
        defer { device.unlockForConfiguration() }
        device.torchMode = mode.captureMode
    }

}

private extension CameraTorchMode {

    var captureMode: AVCaptureDevice.TorchMode {
        switch self {
        case .off:
            .off
        case .on:
            .on
        case .auto:
            .auto
        }
    }

}

private extension AVCaptureDevice.FlashMode {

    var cameraFlashMode: CameraFlashMode? {
        switch self {
        case .off:
            .off
        case .on:
            .on
        case .auto:
            .auto
        @unknown default:
            nil
        }
    }

}
