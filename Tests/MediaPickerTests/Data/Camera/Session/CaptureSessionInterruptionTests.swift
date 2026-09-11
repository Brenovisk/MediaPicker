//
//  CaptureSessionInterruptionTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

@testable import MediaPicker
import Testing

struct CaptureSessionInterruptionTests {

    @Test func interruptionDisablesControlsUntilItEnds() async throws {
        let service = CaptureSessionService(
            operations: CaptureSessionClientSpy().operations
        )
        try await service.open(for: .back)

        await service.handle(.interruptionBegan(.cameraInUse))
        #expect(await service.state == .interrupted(.cameraInUse))
        #expect(await service.canSwitchCamera == false)

        await service.handle(.interruptionEnded)
        #expect(await service.state == .ready)
    }

    @Test func runtimeFailureUsesDomainError() async throws {
        let service = CaptureSessionService(
            operations: CaptureSessionClientSpy().operations
        )
        try await service.open(for: .back)

        await service.handle(.runtimeFailure(.cameraUnavailable))

        #expect(await service.state == .failed(.cameraUnavailable))
    }

    @Test func mediaServicesResetRebuildsSessionOnce() async throws {
        let client = CaptureSessionClientSpy()
        let service = CaptureSessionService(operations: client.operations)
        try await service.open(for: .back)

        await service.handle(.mediaServicesWereReset)

        #expect(client.resetCount == 1)
        #expect(client.configureCount == 2)
        #expect(client.startCount == 2)
        #expect(await service.state == .ready)
    }

    @Test func repeatedResetDoesNotCreateRecoveryLoop() async throws {
        let client = CaptureSessionClientSpy()
        let service = CaptureSessionService(operations: client.operations)
        try await service.open(for: .back)
        await service.handle(.mediaServicesWereReset)

        await service.handle(.mediaServicesWereReset)

        #expect(client.resetCount == 1)
        #expect(client.startCount == 2)
        #expect(await service.state == .failed(.mediaServicesResetRecoveryFailed))
    }

    @Test func observersAreRemovedOnClose() async throws {
        let client = CaptureSessionClientSpy()
        let service = CaptureSessionService(operations: client.operations)

        try await service.open(for: .back)
        try await service.open(for: .back)
        try await service.close()

        #expect(client.startObservingCount == 1)
        #expect(client.stopObservingCount == 1)
    }

}
