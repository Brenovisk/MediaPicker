//
//  CaptureSessionLifecycleTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 09/09/26.
//

@testable import MediaPicker
import Testing

struct CaptureSessionLifecycleTests {

    @Test func openingCameraStartsSessionOnceAndUpdatesState() async throws {
        let client = CaptureSessionClientSpy()
        let service = CaptureSessionService(operations: client.operations)

        try await service.open(for: .back)
        try await service.open(for: .back)

        #expect(client.configureCount == 1)
        #expect(client.startCount == 1)
        #expect(await service.state == .ready)
    }

    @Test func closingCameraStopsAndResetsSession() async throws {
        let client = CaptureSessionClientSpy()
        let service = CaptureSessionService(operations: client.operations)

        try await service.open(for: .back)
        try await service.close()

        #expect(client.stopCount == 1)
        #expect(client.resetCount == 1)
        #expect(await service.state == .idle)
    }

    @Test func closingCameraRepeatedlyDoesNotRepeatOperations() async throws {
        let client = CaptureSessionClientSpy()
        let service = CaptureSessionService(operations: client.operations)
        try await service.open(for: .back)

        try await service.close()
        try await service.close()

        #expect(client.stopCount == 1)
        #expect(client.resetCount == 1)
        #expect(await service.state == .idle)
    }

    @Test func backgroundStopsAndForegroundRestartsActiveSession() async throws {
        let client = CaptureSessionClientSpy()
        let service = CaptureSessionService(operations: client.operations)

        try await service.open(for: .back)

        try await service.applicationDidEnterBackground()
        #expect(client.stopCount == 1)
        #expect(await service.state == .suspended)

        try await service.applicationWillEnterForeground()
        #expect(client.startCount == 2)
        #expect(await service.state == .ready)
    }

    @Test func foregroundDoesNotRestartClosedPicker() async throws {
        let client = CaptureSessionClientSpy()
        let service = CaptureSessionService(operations: client.operations)

        try await service.open(for: .back)
        try await service.close()
        try await service.applicationWillEnterForeground()

        #expect(client.startCount == 1)
        #expect(await service.state == .idle)
    }

}
