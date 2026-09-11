//
//  CaptureSessionStorage.swift
//  MediaPicker
//
//  Created by Breno Lucas on 09/09/26.
//

import AVFoundation

/**
 Owns and mutates the AVFoundation capture session.

 Access is limited by convention to the closures assembled by
 `CaptureSessionOperations.live`, which the capture-service actor serializes.
*/
final class CaptureSessionStorage: @unchecked Sendable {

    let session: AVCaptureSession
    let videoOutput = AVCaptureVideoDataOutput()
    let photoOutput = AVCapturePhotoOutput()
    let deviceDiscovery = CameraDeviceDiscoveryService()

    var configuredPosition: CameraPosition?
    var videoInput: AVCaptureDeviceInput?
    var backCameraInput: AVCaptureDeviceInput?
    var frontCameraInput: AVCaptureDeviceInput?

    private let frameQueue = DispatchQueue(
        label: "com.brenolucas.MediaPicker.preview-frames",
        qos: .userInteractive
    )

    init(session: AVCaptureSession, frameStore: CameraPreviewFrameStore) {
        self.session = session
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(frameStore, queue: frameQueue)
    }

    func configure(for position: CameraPosition) throws {
        guard configuredPosition != position else { return }
        guard configuredPosition == nil else {
            throw CaptureSessionConfigurationError.alreadyConfigured
        }

        let input = try makeVideoInput(for: position)
        try configureSession(with: input)
        videoInput = input
        configuredPosition = position
    }

    func startRunning() {
        enableMultitaskingCameraAccessIfSupported()
        session.startRunning()
    }

    func stopRunning() {
        session.stopRunning()
    }

    func reset() {
        session.beginConfiguration()
        session.inputs.forEach(session.removeInput)
        session.outputs.forEach(session.removeOutput)
        session.commitConfiguration()

        configuredPosition = nil
        videoInput = nil
        backCameraInput = nil
        frontCameraInput = nil
    }

    func prepareCameraSwitch(to position: CameraPosition) {
        _ = try? makeVideoInput(for: position)
    }

    func switchCamera(to position: CameraPosition) throws {
        guard configuredPosition != position else { return }
        guard let currentInput = videoInput else {
            throw CaptureSessionConfigurationError.missingVideoInput
        }

        let newInput = try makeVideoInput(for: position)
        try replaceVideoInput(currentInput, with: newInput)
        videoInput = newInput
        configuredPosition = position
    }

    private func enableMultitaskingCameraAccessIfSupported() {
    #if os(iOS) && !targetEnvironment(macCatalyst)
        guard session.isMultitaskingCameraAccessSupported else { return }
        session.isMultitaskingCameraAccessEnabled = true
    #endif
    }

}

enum CaptureSessionConfigurationError: Error {
    case alreadyConfigured
    case unsupportedPreset
    case cannotAddVideoInput
    case cannotAddVideoOutput
    case missingVideoInput
    case unsupportedTorchMode
}
