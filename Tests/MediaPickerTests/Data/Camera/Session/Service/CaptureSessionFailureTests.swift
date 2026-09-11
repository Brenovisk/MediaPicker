//
//  CaptureSessionFailureTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 09/09/26.
//

@testable import MediaPicker
import Testing

struct CaptureSessionFailureTests {

    @Test func startFailureMapsToDomainError() async {
        let client = CaptureSessionClientSpy(
            error: CaptureSessionClientError.failure,
            failingOperation: .start
        )
        let service = CaptureSessionService(operations: client.operations)

        await #expect(throws: MediaPickerError.captureSessionStartFailed) {
            try await service.open(for: .back)
        }
    }

    @Test func stopFailureMapsToDomainError() async {
        let client = CaptureSessionClientSpy(
            error: CaptureSessionClientError.failure,
            failingOperation: .stop
        )
        let service = CaptureSessionService(operations: client.operations)
        try? await service.open(for: .back)

        await #expect(throws: MediaPickerError.captureSessionStopFailed) {
            try await service.close()
        }
        #expect(await service.state == .failed(.captureSessionStopFailed))
    }

}
