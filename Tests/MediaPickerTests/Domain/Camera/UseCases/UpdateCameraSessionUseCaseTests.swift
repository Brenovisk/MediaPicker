//
//  UpdateCameraSessionUseCaseTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

@testable import MediaPicker
import Testing

struct UpdateCameraSessionUseCaseTests {

    @Test func enteringBackgroundSuspendsSession() async throws {
        let controller = CameraSessionControllerSpy()
        let useCase = UpdateCameraSessionUseCase(cameraSession: controller)

        let snapshot = try await useCase.execute(event: .enteredBackground)

        #expect(await controller.operations == [.enteredBackground])
        #expect(snapshot.state == .suspended)
    }

    @Test func enteringForegroundResumesSession() async throws {
        let controller = CameraSessionControllerSpy(state: .suspended)
        let useCase = UpdateCameraSessionUseCase(cameraSession: controller)

        let snapshot = try await useCase.execute(event: .enteredForeground)

        #expect(await controller.operations == [.enteredForeground])
        #expect(snapshot.state == .ready)
    }

    @Test func propagatesLifecycleFailure() async {
        let controller = CameraSessionControllerSpy(failure: .enteredBackground)
        let useCase = UpdateCameraSessionUseCase(cameraSession: controller)

        await #expect(throws: CameraSessionControllerSpyError.failure) {
            try await useCase.execute(event: .enteredBackground)
        }
    }

    @Test func observationForwardsAsynchronousSessionState() async {
        let controller = CameraSessionControllerSpy()
        let useCase = UpdateCameraSessionUseCase(cameraSession: controller)
        let expected = CameraSessionSnapshot(
            state: .interrupted(.systemPressure),
            position: .back,
            canCapturePhoto: false,
            lightingCapabilities: .unavailable,
            flashMode: .off,
            torchMode: .off
        )
        let updates = await useCase.observe()

        await controller.send(expected)
        let received = await updates.first(where: { _ in true })

        #expect(received?.state == expected.state)
        #expect(received?.position == expected.position)
    }

}
