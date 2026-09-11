//
//  CaptureSessionExecutionTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 09/09/26.
//

@testable import MediaPicker
import Testing

struct CaptureSessionExecutionTests {

    @Test @MainActor func startAndStopDoNotRunOnTheMainThread() async throws {
        let client = CaptureSessionClientSpy()
        let service = CaptureSessionService(operations: client.operations)

        try await service.open(for: .back)
        try await service.close()

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
                    try? await service.open(for: .back)
                }
            }
        }

        #expect(client.maximumConcurrentOperations == 1)
        #expect(client.startCount == 1)
    }

}
