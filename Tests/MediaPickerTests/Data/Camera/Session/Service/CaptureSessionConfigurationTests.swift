//
//  CaptureSessionConfigurationTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 09/09/26.
//

@testable import MediaPicker
import Testing

struct CaptureSessionConfigurationTests {

    @Test func configurationAddsVideoInputOnce() async throws {
        let client = CaptureSessionClientSpy()
        let service = CaptureSessionService(operations: client.operations)

        try await service.configure(for: .back)
        try await service.configure(for: .back)

        #expect(client.configureCount == 1)
        #expect(client.configuredPositions == [.back])
    }

    @Test func differentPositionIsRejectedAfterConfiguration() async throws {
        let client = CaptureSessionClientSpy()
        let service = CaptureSessionService(operations: client.operations)
        try await service.configure(for: .back)

        await #expect(throws: MediaPickerError.captureSessionConfigurationFailed) {
            try await service.configure(for: .front)
        }
        #expect(client.configureCount == 1)
    }

    @Test func failedConfigurationCanBeRetriedWithoutCorruptingState() async {
        let client = CaptureSessionClientSpy(
            error: CaptureSessionClientError.failure,
            failingOperation: .configure
        )
        let service = CaptureSessionService(operations: client.operations)

        await #expect(throws: MediaPickerError.captureSessionConfigurationFailed) {
            try await service.configure(for: .back)
        }
        await #expect(throws: MediaPickerError.captureSessionConfigurationFailed) {
            try await service.configure(for: .back)
        }

        #expect(client.configureCount == 2)
    }

    @Test func discoveryAvailabilityErrorIsPreserved() async {
        let client = CaptureSessionClientSpy(
            error: MediaPickerError.sourceUnavailable(.camera)
        )
        let service = CaptureSessionService(operations: client.operations)

        await #expect(throws: MediaPickerError.sourceUnavailable(.camera)) {
            try await service.configure(for: .back)
        }
    }

    @Test func availablePhotoOutputIsReadyAfterSessionPreparation() async throws {
        let capabilities = CameraPhotoOutputCapabilities(
            isAvailable: true,
            flashModes: [.off, .on, .auto]
        )
        let client = CaptureSessionClientSpy(photoCapabilities: capabilities)
        let service = CaptureSessionService(operations: client.operations)

        #expect(await service.canCapturePhoto == false)

        try await service.open(for: .back)

        #expect(await service.photoOutputCapabilities == capabilities)
        #expect(await service.canCapturePhoto)
    }

    @Test func unavailablePhotoOutputDoesNotInvalidatePreparedSession() async throws {
        let client = CaptureSessionClientSpy(photoCapabilities: .unavailable)
        let service = CaptureSessionService(operations: client.operations)

        try await service.open(for: .back)

        #expect(await service.state == .ready)
        #expect(await service.canCapturePhoto == false)
        #expect(client.startCount == 1)
    }

    @Test func resetClearsPhotoOutputReadiness() async throws {
        let capabilities = CameraPhotoOutputCapabilities(
            isAvailable: true,
            flashModes: [.off]
        )
        let client = CaptureSessionClientSpy(photoCapabilities: capabilities)
        let service = CaptureSessionService(operations: client.operations)
        try await service.open(for: .back)

        try await service.close()

        #expect(await service.photoOutputCapabilities == .unavailable)
        #expect(await service.canCapturePhoto == false)
    }

}
