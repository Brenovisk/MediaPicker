//
//  CaptureSessionStorage+Configuration.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

import AVFoundation

/** Configures session inputs and outputs as one recoverable transaction. */
extension CaptureSessionStorage {

    func configureSession(with videoInput: AVCaptureDeviceInput) throws {
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        guard session.canAddInput(videoInput) else {
            throw CaptureSessionConfigurationError.cannotAddVideoInput
        }

        session.addInput(videoInput)

        do {
            try configurePreset()
            try configureVideoOutput()
            configurePhotoOutputIfSupported()
        } catch {
            rollbackConfiguration(videoInput: videoInput)
            throw error
        }
    }

    private func configurePreset() throws {
        guard session.canSetSessionPreset(.photo) else {
            throw CaptureSessionConfigurationError.unsupportedPreset
        }
        session.sessionPreset = .photo
    }

    private func configureVideoOutput() throws {
        guard session.canAddOutput(videoOutput) else {
            throw CaptureSessionConfigurationError.cannotAddVideoOutput
        }
        session.addOutput(videoOutput)
    }

    private func configurePhotoOutputIfSupported() {
        guard session.canAddOutput(photoOutput) else { return }
        session.addOutput(photoOutput)
    }

    private func rollbackConfiguration(videoInput: AVCaptureDeviceInput) {
        session.removeInput(videoInput)

        if session.outputs.contains(videoOutput) {
            session.removeOutput(videoOutput)
        }

        if session.outputs.contains(photoOutput) {
            session.removeOutput(photoOutput)
        }
    }

}
