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

}
