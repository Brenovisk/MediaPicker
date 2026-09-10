//
//  CaptureSessionStorage.swift
//  MediaPicker
//
//  Created by Breno Lucas on 09/09/26.
//

import AVFoundation

extension CaptureSessionOperations {

    static var live: CaptureSessionOperations {
        let previewSession = CaptureSessionReference()

        let storage = CaptureSessionStorage(
            session: previewSession.session,
            frameStore: previewSession.frameStore
        )

        return CaptureSessionOperations(
            previewSession: previewSession,
            configure: storage.configure,
            reset: storage.reset,
            startRunning: storage.startRunning,
            stopRunning: storage.stopRunning,
            prepareCameraSwitch: storage.prepareCameraSwitch,
            switchCamera: storage.switchCamera,
            lightingCapabilities: storage.lightingCapabilities,
            setTorchMode: storage.setTorchMode
        )
    }

}

/**
 The only type that owns and directly mutates `AVCaptureSession`.

 The storage is private to this file. Only the closures in `.live` can reach it,
 and `CaptureSessionService` executes those closures on its serial executor.
*/
private final class CaptureSessionStorage: @unchecked Sendable {

    private let session: AVCaptureSession
    private let frameStore: CameraPreviewFrameStore
    private let videoOutput = AVCaptureVideoDataOutput()

    private let frameQueue = DispatchQueue(
        label: "com.brenolucas.MediaPicker.preview-frames",
        qos: .userInteractive
    )

    private let deviceDiscovery = CameraDeviceDiscoveryService()
    private var configuredPosition: CameraPosition?

    private var videoInput: AVCaptureDeviceInput?
    private var backCameraInput: AVCaptureDeviceInput?
    private var frontCameraInput: AVCaptureDeviceInput?

    init(session: AVCaptureSession, frameStore: CameraPreviewFrameStore) {
        self.session = session
        self.frameStore = frameStore
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(frameStore, queue: frameQueue)
    }

    func configure(for position: CameraPosition) throws {
        guard configuredPosition != position else { return }
        guard configuredPosition == nil else {
            throw CaptureSessionConfigurationError.alreadyConfigured
        }

        let videoInput = try makeVideoInput(for: position)

        try configureSession(with: videoInput)
        self.videoInput = videoInput
        configuredPosition = position
    }

    func startRunning() {
        session.startRunning()
    }

    func reset() {
        session.beginConfiguration()

        for input in session.inputs {
            session.removeInput(input)
        }

        for output in session.outputs {
            session.removeOutput(output)
        }

        configuredPosition = nil
        videoInput = nil
        backCameraInput = nil
        frontCameraInput = nil
        session.commitConfiguration()
    }

    func stopRunning() {
        session.stopRunning()
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

// MARK: Helper Methods
extension CaptureSessionStorage {

    private func configureSession(with videoInput: AVCaptureDeviceInput) throws {
        session.beginConfiguration()

        defer {
            session.commitConfiguration()
        }

        guard session.canAddInput(videoInput) else {
            throw CaptureSessionConfigurationError.cannotAddVideoInput
        }

        session.addInput(videoInput)

        do {
            try configurePreset()
            try configureVideoOutput()
        } catch {
            session.removeInput(videoInput)
            if session.outputs.contains(videoOutput) {
                session.removeOutput(videoOutput)
            }
            throw error
        }
    }

    private func configurePreset() throws {
        guard session.canSetSessionPreset(.high) else {
            throw CaptureSessionConfigurationError.unsupportedPreset
        }

        session.sessionPreset = .high
    }

    private func configureVideoOutput() throws {
        guard session.canAddOutput(videoOutput) else {
            throw CaptureSessionConfigurationError.cannotAddVideoOutput
        }

        session.addOutput(videoOutput)
    }

    private func replaceVideoInput(
        _ currentInput: AVCaptureDeviceInput,
        with newInput: AVCaptureDeviceInput
    ) throws {
        session.beginConfiguration()

        defer {
            session.commitConfiguration()
        }

        session.removeInput(currentInput)

        guard session.canAddInput(newInput) else {
            restoreVideoInput(currentInput)
            throw CaptureSessionConfigurationError.cannotAddVideoInput
        }

        session.addInput(newInput)
    }

    private func restoreVideoInput(_ input: AVCaptureDeviceInput) {
        guard session.canAddInput(input) else { return }
        session.addInput(input)
    }

    private func makeVideoInput(for position: CameraPosition) throws -> AVCaptureDeviceInput {
        if let preparedInput = preparedInput(for: position) {
            return preparedInput
        }

        let device = try deviceDiscovery.discoverDevice(for: position)
        let input = try AVCaptureDeviceInput(device: device)
        storePreparedInput(input, for: position)
        return input
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

private enum CaptureSessionConfigurationError: Error {
    case alreadyConfigured
    case unsupportedPreset
    case cannotAddVideoInput
    case cannotAddVideoOutput
    case missingVideoInput
    case unsupportedTorchMode
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
