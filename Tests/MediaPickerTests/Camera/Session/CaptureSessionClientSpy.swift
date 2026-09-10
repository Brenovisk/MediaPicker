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
}

final class CaptureSessionClientSpy: @unchecked Sendable {

    private let lock = NSLock()
    private let operationDuration: TimeInterval
    private let error: (any Error)?
    private let failingOperation: CaptureSessionClientOperation
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

    init(
        operationDuration: TimeInterval = .zero,
        error: (any Error)? = nil,
        failingOperation: CaptureSessionClientOperation = .all
    ) {
        self.operationDuration = operationDuration
        self.error = error
        self.failingOperation = failingOperation
    }

    var operations: CaptureSessionOperations {
        CaptureSessionOperations(
            configure: configure,
            reset: reset,
            startRunning: startRunning,
            stopRunning: stopRunning,
            prepareCameraSwitch: prepareCameraSwitch,
            switchCamera: switchCamera
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
