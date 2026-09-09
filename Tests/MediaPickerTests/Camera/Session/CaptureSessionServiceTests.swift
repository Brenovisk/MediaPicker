@testable import MediaPicker
import Testing

struct CaptureSessionServiceTests {

    @Test @MainActor func startAndStopDoNotRunOnTheMainThread() async throws {
        let client = CaptureSessionClientSpy()
        let service = CaptureSessionService(operations: client.operations)

        try await service.startRunning()
        try await service.stopRunning()

        #expect(client.didRunOnMainThread == false)
        #expect(client.startCount == 1)
        #expect(client.stopCount == 1)
    }

    @Test func concurrentCommandsAreSerialized() async {
        let client = CaptureSessionClientSpy(operationDuration: 0.01)
        let service = CaptureSessionService(operations: client.operations)

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    try? await service.startRunning()
                }
            }
        }

        #expect(client.maximumConcurrentOperations == 1)
        #expect(client.startCount == 10)
    }

    @Test func startFailureMapsToDomainError() async {
        let client = CaptureSessionClientSpy(error: CaptureSessionClientError.failure)
        let service = CaptureSessionService(operations: client.operations)

        await #expect(throws: MediaPickerError.captureSessionStartFailed) {
            try await service.startRunning()
        }
    }

    @Test func stopFailureMapsToDomainError() async {
        let client = CaptureSessionClientSpy(error: CaptureSessionClientError.failure)
        let service = CaptureSessionService(operations: client.operations)

        await #expect(throws: MediaPickerError.captureSessionStopFailed) {
            try await service.stopRunning()
        }
    }

}
