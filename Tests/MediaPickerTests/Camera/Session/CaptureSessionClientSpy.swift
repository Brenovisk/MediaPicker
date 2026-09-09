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

final class CaptureSessionClientSpy: @unchecked Sendable {

    private let lock = NSLock()
    private let operationDuration: TimeInterval
    private let error: (any Error)?
    private var activeOperations = 0
    private(set) var maximumConcurrentOperations = 0
    private(set) var didRunOnMainThread = false
    private(set) var configureCount = 0
    private(set) var configuredPositions: [CameraPosition] = []
    private(set) var startCount = 0
    private(set) var stopCount = 0

    init(
        operationDuration: TimeInterval = .zero,
        error: (any Error)? = nil
    ) {
        self.operationDuration = operationDuration
        self.error = error
    }

    var operations: CaptureSessionOperations {
        CaptureSessionOperations(
            configure: configure,
            startRunning: startRunning,
            stopRunning: stopRunning
        )
    }

    func configure(for position: CameraPosition) throws {
        try performOperation {
            configureCount += 1
            configuredPositions.append(position)
        }
    }

    func startRunning() throws {
        try performOperation {
            startCount += 1
        }
    }

    func stopRunning() throws {
        try performOperation {
            stopCount += 1
        }
    }

    private func performOperation(_ updateCount: () -> Void) throws {
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

        if let error {
            throw error
        }
    }

}
