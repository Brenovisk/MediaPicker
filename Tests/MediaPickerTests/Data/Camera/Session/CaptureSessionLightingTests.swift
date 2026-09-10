//
//  CaptureSessionLightingTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

@testable import MediaPicker
import Testing

struct CaptureSessionLightingTests {

    @Test func openingSessionPublishesActiveDeviceCapabilities() async throws {
        let capabilities = CameraLightingCapabilities(
            flashModes: [.off, .on, .auto],
            torchModes: [.off, .on]
        )
        let client = CaptureSessionClientSpy(capabilities: [capabilities])
        let service = CaptureSessionService(operations: client.operations)

        try await service.open(for: .back)

        #expect(await service.lightingCapabilities == capabilities)
    }

    @Test func switchingCameraRefreshesLightingCapabilities() async throws {
        let backCapabilities = CameraLightingCapabilities(
            flashModes: [.off, .on],
            torchModes: [.off, .on]
        )
        let frontCapabilities = CameraLightingCapabilities.unavailable
        let client = CaptureSessionClientSpy(
            capabilities: [backCapabilities, frontCapabilities]
        )
        let service = CaptureSessionService(operations: client.operations)
        try await service.open(for: .back)

        try await service.switchCamera()

        #expect(await service.lightingCapabilities == frontCapabilities)
        #expect(await service.flashMode == .off)
        #expect(await service.torchMode == .off)
    }

    @Test func supportedTorchModeLocksAndConfiguresThroughOperation() async throws {
        let capabilities = CameraLightingCapabilities(torchModes: [.off, .on])
        let client = CaptureSessionClientSpy(capabilities: [capabilities])
        let service = CaptureSessionService(operations: client.operations)
        try await service.open(for: .back)

        try await service.setTorchMode(.on)

        #expect(await service.torchMode == .on)
        #expect(client.selectedTorchModes == [.on])
    }

    @Test func unsupportedModesFailWithoutTouchingHardware() async throws {
        let client = CaptureSessionClientSpy(capabilities: [.unavailable])
        let service = CaptureSessionService(operations: client.operations)
        try await service.open(for: .front)

        await #expect(throws: MediaPickerError.unsupportedFlashMode) {
            try await service.setFlashMode(.on)
        }
        await #expect(throws: MediaPickerError.unsupportedTorchMode) {
            try await service.setTorchMode(.on)
        }
        #expect(client.selectedTorchModes.isEmpty)
    }

    @Test func torchConfigurationFailureMapsToDomainError() async throws {
        let capabilities = CameraLightingCapabilities(torchModes: [.off, .on])
        let client = CaptureSessionClientSpy(
            error: CaptureSessionClientError.failure,
            failingOperation: .setTorchMode,
            capabilities: [capabilities]
        )
        let service = CaptureSessionService(operations: client.operations)
        try await service.open(for: .back)

        await #expect(throws: MediaPickerError.cameraDeviceConfigurationFailed) {
            try await service.setTorchMode(.on)
        }
    }

}
