//
//  CameraSessionControllerSpy.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

import Foundation
@testable import MediaPicker

enum CameraSessionControllerSpyError: Error {
    case failure
}

enum CameraSessionControllerOperation: Equatable {
    case open(CameraPosition)
    case close
    case enteredBackground
    case enteredForeground
    case switchCamera
    case capturePhoto(PhotoOutputFormat, Double, CameraPreviewFraming?)
    case setFlashMode(CameraFlashMode)
    case setTorchMode(CameraTorchMode)
}

actor CameraSessionControllerSpy: CameraSessionControlling {

    private var positions: [CameraPosition]
    private let failure: CameraSessionControllerOperation?
    private(set) var operations: [CameraSessionControllerOperation] = []
    private(set) var state: CameraState
    private(set) var activeCameraPosition: CameraPosition?
    private(set) var canCapturePhoto: Bool
    private(set) var lightingCapabilities: CameraLightingCapabilities
    private(set) var flashMode: CameraFlashMode
    private(set) var torchMode: CameraTorchMode
    private let updateStream: AsyncStream<CameraSessionSnapshot>
    private let updateContinuation: AsyncStream<CameraSessionSnapshot>.Continuation
    private var nextPhotoID = UUID()

    init(
        positions: [CameraPosition] = [],
        state: CameraState = .ready,
        activePosition: CameraPosition? = .back,
        canCapturePhoto: Bool = true,
        lightingCapabilities: CameraLightingCapabilities = .unavailable,
        flashMode: CameraFlashMode = .off,
        torchMode: CameraTorchMode = .off,
        failure: CameraSessionControllerOperation? = nil
    ) {
        let updates = AsyncStream<CameraSessionSnapshot>.makeStream(
            bufferingPolicy: .bufferingNewest(1)
        )
        self.positions = positions
        self.state = state
        activeCameraPosition = activePosition
        self.canCapturePhoto = canCapturePhoto
        self.lightingCapabilities = lightingCapabilities
        self.flashMode = flashMode
        self.torchMode = torchMode
        self.failure = failure
        updateStream = updates.stream
        updateContinuation = updates.continuation
    }

    func open(for position: CameraPosition) throws {
        try record(.open(position))
        activeCameraPosition = position
        state = .ready
    }

    func close() throws {
        try record(.close)
        activeCameraPosition = nil
        state = .idle
    }

    func applicationDidEnterBackground() throws {
        try record(.enteredBackground)
        state = .suspended
    }

    func applicationWillEnterForeground() throws {
        try record(.enteredForeground)
        state = .ready
    }

    func switchCamera() throws -> CameraPosition {
        try record(.switchCamera)
        let position = positions.removeFirst()
        activeCameraPosition = position
        return position
    }

    func capturePhoto(
        format: PhotoOutputFormat,
        rotationAngle: Double,
        previewFraming: CameraPreviewFraming?
    ) throws -> CapturedMedia {
        try record(.capturePhoto(format, rotationAngle, previewFraming))
        defer { nextPhotoID = UUID() }
        return CapturedMedia(
            id: nextPhotoID,
            mediaType: .photo,
            source: .camera,
            contentURL: URL(fileURLWithPath: "/tmp/photo.jpg")
        )
    }

    func setFlashMode(_ mode: CameraFlashMode) throws {
        try record(.setFlashMode(mode))
        flashMode = mode
    }

    func setTorchMode(_ mode: CameraTorchMode) throws {
        try record(.setTorchMode(mode))
        torchMode = mode
    }

    func updates() -> AsyncStream<CameraSessionSnapshot> {
        updateStream
    }

    func send(_ snapshot: CameraSessionSnapshot) {
        updateContinuation.yield(snapshot)
    }

    private func record(_ operation: CameraSessionControllerOperation) throws {
        operations.append(operation)

        if failure == operation {
            throw CameraSessionControllerSpyError.failure
        }
    }

}
