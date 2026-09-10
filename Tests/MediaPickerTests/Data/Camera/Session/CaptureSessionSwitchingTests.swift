//
//  CaptureSessionSwitchingTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

@testable import MediaPicker
import Testing

struct CaptureSessionSwitchingTests {

    @Test func switchingCameraReplacesInputWithoutRestartingSession() async throws {
        let client = CaptureSessionClientSpy()
        let service = CaptureSessionService(operations: client.operations)
        try await service.open(for: .back)

        let activePosition = try await service.switchCamera()

        #expect(activePosition == .front)
        #expect(await service.activeCameraPosition == .front)
        #expect(client.preparedSwitchPositions == [.front])
        #expect(client.switchedPositions == [.front])
        #expect(client.startCount == 1)
        #expect(client.stopCount == 0)
        #expect(await service.state == .ready)
    }

    @Test func repeatedSwitchesAlternateBetweenFrontAndBack() async throws {
        let client = CaptureSessionClientSpy()
        let service = CaptureSessionService(operations: client.operations)
        try await service.open(for: .back)

        try await service.switchCamera()
        try await service.switchCamera()

        #expect(client.switchedPositions == [.front, .back])
        #expect(await service.activeCameraPosition == .back)
        #expect(client.startCount == 1)
    }

    @Test func failedSwitchPreservesActiveCamera() async throws {
        let client = CaptureSessionClientSpy(
            error: CaptureSessionClientError.failure,
            failingOperation: .switchCamera
        )
        let service = CaptureSessionService(operations: client.operations)
        try await service.open(for: .back)

        await #expect(throws: MediaPickerError.captureSessionSwitchFailed) {
            try await service.switchCamera()
        }

        #expect(await service.activeCameraPosition == .back)
        #expect(await service.state == .ready)
        #expect(client.startCount == 1)
    }

    @Test func switchingIsRejectedWhileSessionIsSuspended() async throws {
        let client = CaptureSessionClientSpy()
        let service = CaptureSessionService(operations: client.operations)
        try await service.open(for: .back)
        try await service.applicationDidEnterBackground()

        #expect(await service.canSwitchCamera == false)
        await #expect(throws: MediaPickerError.captureSessionSwitchFailed) {
            try await service.switchCamera()
        }
        #expect(client.switchCount == 0)
        #expect(await service.activeCameraPosition == .back)
    }

}
