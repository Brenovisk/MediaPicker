//
//  CaptureSessionClientSpy.swift
//  MediaPicker
//
//  Created by Breno Lucas on 09/09/26.
//

import Foundation
@testable import MediaPicker

enum CaptureSessionClientError: Error {
    case failure
}

enum CaptureSessionClientOperation: Equatable {
    case all
    case configure
    case start
    case stop
    case switchCamera
    case capturePhoto
    case setTorchMode
}

final class CaptureSessionClientSpy: @unchecked Sendable {

    private let lock = NSLock()
    private let operationDuration: TimeInterval
    private let error: (any Error)?
    private let failingOperation: CaptureSessionClientOperation
    private var capabilities: [CameraLightingCapabilities]
    private let photoCapabilities: CameraPhotoOutputCapabilities
    private var activeOperations = 0
    private(set) var maximumConcurrentOperations = 0
    private(set) var didRunOnMainThread = false
    private(set) var configureCount = 0
    private(set) var configuredPositions: [CameraPosition] = []
    private(set) var resetCount = 0
    private(set) var startCount = 0
    private(set) var stopCount = 0
    private(set) var switchCount = 0
    private(set) var switchedPositions: [CameraPosition] = []
    private(set) var preparedSwitchPositions: [CameraPosition] = []
    private(set) var selectedTorchModes: [CameraTorchMode] = []
    private(set) var capturedFlashModes: [CameraFlashMode] = []
    private(set) var captureCount = 0
    private(set) var startObservingCount = 0
    private(set) var stopObservingCount = 0
    private var eventHandler: (@Sendable (CameraSessionEvent) -> Void)?

    init(
        operationDuration: TimeInterval = .zero,
        error: (any Error)? = nil,
        failingOperation: CaptureSessionClientOperation = .all,
        capabilities: [CameraLightingCapabilities] = [.unavailable],
        photoCapabilities: CameraPhotoOutputCapabilities = .unavailable
    ) {
        self.operationDuration = operationDuration
        self.error = error
        self.failingOperation = failingOperation
        self.capabilities = capabilities
        self.photoCapabilities = photoCapabilities
    }

    var operations: CaptureSessionOperations {
        CaptureSessionOperations(
            configure: configure,
            reset: reset,
            startRunning: startRunning,
            stopRunning: stopRunning,
            prepareCameraSwitch: prepareCameraSwitch,
            switchCamera: switchCamera,
            lightingCapabilities: lightingCapabilities,
            photoOutputCapabilities: photoOutputCapabilities,
            capturePhoto: capturePhoto,
            setTorchMode: setTorchMode,
            startObservingEvents: startObservingEvents,
            stopObservingEvents: stopObservingEvents
        )
    }

    func reset() {
        lock.lock()
        resetCount += 1
        lock.unlock()
    }

    func configure(for position: CameraPosition) throws {
        try performOperation(.configure) {
            configureCount += 1
            configuredPositions.append(position)
        }
    }

    func startRunning() throws {
        try performOperation(.start) {
            startCount += 1
        }
    }

    func stopRunning() throws {
        try performOperation(.stop) {
            stopCount += 1
        }
    }

    func switchCamera(to position: CameraPosition) throws {
        try performOperation(.switchCamera) {
            switchCount += 1
            switchedPositions.append(position)
        }
    }

    func prepareCameraSwitch(to position: CameraPosition) {
        lock.lock()
        preparedSwitchPositions.append(position)
        lock.unlock()
    }

    func lightingCapabilities() -> CameraLightingCapabilities {
        lock.withLock {
            guard capabilities.count > 1 else {
                return capabilities.first ?? .unavailable
            }

            return capabilities.removeFirst()
        }
    }

    func photoOutputCapabilities() -> CameraPhotoOutputCapabilities {
        photoCapabilities
    }

    func capturePhoto(
        flashMode: CameraFlashMode
    ) async throws -> CameraPhotoCaptureRequest {
        let requestID = lock.withLock { () -> Int64 in
            captureCount += 1
            capturedFlashModes.append(flashMode)
            return Int64(captureCount)
        }

        if operationDuration > .zero {
            try await Task.sleep(for: .seconds(operationDuration))
        }

        if let error, failingOperation == .all || failingOperation == .capturePhoto {
            throw error
        }

        return CameraPhotoCaptureRequest(id: requestID)
    }

    func setTorchMode(_ mode: CameraTorchMode) throws {
        try performOperation(.setTorchMode) {
            selectedTorchModes.append(mode)
        }
    }

    func startObservingEvents(
        _ handler: @escaping @Sendable (CameraSessionEvent) -> Void
    ) {
        lock.withLock {
            startObservingCount += 1
            eventHandler = handler
        }
    }

    func stopObservingEvents() {
        lock.withLock {
            stopObservingCount += 1
            eventHandler = nil
        }
    }

    func send(_ event: CameraSessionEvent) {
        lock.withLock { eventHandler }?(event)
    }

    private func performOperation(
        _ operation: CaptureSessionClientOperation,
        updateCount: () -> Void
    ) throws {
        lock.lock()
        activeOperations += 1
        maximumConcurrentOperations = max(maximumConcurrentOperations, activeOperations)
        didRunOnMainThread = didRunOnMainThread || Thread.isMainThread
        updateCount()
        lock.unlock()

        Thread.sleep(forTimeInterval: operationDuration)

        lock.lock()
        activeOperations -= 1
        lock.unlock()

        if let error, failingOperation == .all || failingOperation == operation {
            throw error
        }
    }

}
