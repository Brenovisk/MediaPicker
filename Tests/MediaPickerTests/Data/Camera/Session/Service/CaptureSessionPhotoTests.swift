//
//  CaptureSessionPhotoTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

@testable import MediaPicker
import Testing

struct CaptureSessionPhotoTests {

    private let availablePhotoOutput = CameraPhotoOutputCapabilities(
        isAvailable: true,
        flashModes: [.off, .on, .auto]
    )

    @Test func captureIsRejectedUntilSessionIsReady() async {
        let client = CaptureSessionClientSpy(photoCapabilities: availablePhotoOutput)
        let service = CaptureSessionService(operations: client.operations)

        await #expect(throws: MediaPickerError.photoCaptureFailed) {
            try await service.capturePhoto(format: .jpeg, rotationAngle: 0)
        }

        #expect(client.captureCount == 0)
    }

    @Test func captureUsesSelectedSupportedFlashMode() async throws {
        let lighting = CameraLightingCapabilities(flashModes: [.off, .auto])
        let client = CaptureSessionClientSpy(
            capabilities: [lighting],
            photoCapabilities: availablePhotoOutput
        )
        let service = CaptureSessionService(operations: client.operations)
        try await service.open(for: .back)
        try await service.setFlashMode(.auto)
        let framing = CameraPreviewFraming(aspectRatio: 16.0 / 9.0)

        _ = try await service.capturePhoto(
            format: .png,
            rotationAngle: 90,
            previewFraming: framing
        )

        #expect(client.capturedFlashModes == [.auto])
        #expect(client.capturedPhotoFormats == [.png])
        #expect(client.photoCaptureOptions.first?.previewFraming == framing)
    }

    @Test func unsupportedOutputFlashModeFallsBackToOff() async throws {
        let lighting = CameraLightingCapabilities(flashModes: [.off, .on])
        let output = CameraPhotoOutputCapabilities(isAvailable: true, flashModes: [.off])
        let client = CaptureSessionClientSpy(
            capabilities: [lighting],
            photoCapabilities: output
        )
        let service = CaptureSessionService(operations: client.operations)
        try await service.open(for: .back)
        try await service.setFlashMode(.on)

        _ = try await service.capturePhoto(format: .jpeg, rotationAngle: 0)

        #expect(client.capturedFlashModes == [.off])
    }

    @Test func simultaneousCaptureIsRejectedWithoutStartingAnotherRequest() async throws {
        let client = CaptureSessionClientSpy(
            operationDuration: 0.05,
            photoCapabilities: availablePhotoOutput
        )
        let service = CaptureSessionService(operations: client.operations)
        try await service.open(for: .back)

        let firstCapture = Task {
            try await service.capturePhoto(format: .jpeg, rotationAngle: 0)
        }
        while await service.state != .capturingPhoto {
            await Task.yield()
        }

        await #expect(throws: MediaPickerError.photoCaptureFailed) {
            try await service.capturePhoto(format: .jpeg, rotationAngle: 0)
        }
        _ = try await firstCapture.value

        #expect(client.captureCount == 1)
        #expect(await service.state == .ready)
    }

    @Test func failedCaptureCompletesOnceAndReturnsSessionToReady() async throws {
        let client = CaptureSessionClientSpy(
            error: CaptureSessionClientError.failure,
            failingOperation: .capturePhoto,
            photoCapabilities: availablePhotoOutput
        )
        let service = CaptureSessionService(operations: client.operations)
        try await service.open(for: .back)

        await #expect(throws: MediaPickerError.photoCaptureFailed) {
            try await service.capturePhoto(format: .jpeg, rotationAngle: 0)
        }

        #expect(client.captureCount == 1)
        #expect(await service.state == .ready)
    }

    @Test func eachCaptureReceivesAUniqueRequestIdentifier() async throws {
        let client = CaptureSessionClientSpy(photoCapabilities: availablePhotoOutput)
        let service = CaptureSessionService(operations: client.operations)
        try await service.open(for: .back)

        let first = try await service.capturePhoto(format: .jpeg, rotationAngle: 0)
        let second = try await service.capturePhoto(format: .jpeg, rotationAngle: 0)

        #expect(first.contentURL != second.contentURL)
    }

}
