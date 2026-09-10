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
        let storage = CaptureSessionStorage(session: previewSession.session)

        return CaptureSessionOperations(
            previewSession: previewSession,
            configure: storage.configure,
            reset: storage.reset,
            startRunning: storage.startRunning,
            stopRunning: storage.stopRunning
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
    private let deviceDiscovery = CameraDeviceDiscoveryService()
    private var configuredPosition: CameraPosition?

    init(session: AVCaptureSession) {
        self.session = session
    }

    func configure(for position: CameraPosition) throws {
        guard configuredPosition != position else { return }
        guard configuredPosition == nil else {
            throw CaptureSessionConfigurationError.alreadyConfigured
        }

        let device = try deviceDiscovery.discoverDevice(for: position)
        let videoInput = try AVCaptureDeviceInput(device: device)

        try configureSession(with: videoInput)
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
        session.commitConfiguration()
    }

    func stopRunning() {
        session.stopRunning()
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
        } catch {
            session.removeInput(videoInput)
            throw error
        }
    }

    private func configurePreset() throws {
        guard session.canSetSessionPreset(.high) else {
            throw CaptureSessionConfigurationError.unsupportedPreset
        }

        session.sessionPreset = .high
    }

}

private enum CaptureSessionConfigurationError: Error {
    case alreadyConfigured
    case unsupportedPreset
    case cannotAddVideoInput
}
