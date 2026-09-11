//
//  CaptureSessionStorage+CameraInput.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

import AVFoundation

/** Creates, caches and safely replaces camera-device inputs. */
extension CaptureSessionStorage {

    func replaceVideoInput(
        _ currentInput: AVCaptureDeviceInput,
        with newInput: AVCaptureDeviceInput
    ) throws {
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        session.removeInput(currentInput)

        guard session.canAddInput(newInput) else {
            restoreVideoInput(currentInput)
            throw CaptureSessionConfigurationError.cannotAddVideoInput
        }

        session.addInput(newInput)
    }

    func makeVideoInput(for position: CameraPosition) throws -> AVCaptureDeviceInput {
        if let preparedInput = preparedInput(for: position) {
            return preparedInput
        }

        let device = try deviceDiscovery.discoverDevice(for: position)
        let input = try AVCaptureDeviceInput(device: device)
        storePreparedInput(input, for: position)
        return input
    }

    private func restoreVideoInput(_ input: AVCaptureDeviceInput) {
        guard session.canAddInput(input) else { return }
        session.addInput(input)
    }

    private func preparedInput(for position: CameraPosition) -> AVCaptureDeviceInput? {
        switch position {
        case .back:
            backCameraInput
        case .front:
            frontCameraInput
        }
    }

    private func storePreparedInput(
        _ input: AVCaptureDeviceInput,
        for position: CameraPosition
    ) {
        switch position {
        case .back:
            backCameraInput = input
        case .front:
            frontCameraInput = input
        }
    }

}
