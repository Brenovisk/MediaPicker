//
//  SetCameraTorchModeUseCaseTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

@testable import MediaPicker
import Testing

struct SetCameraTorchModeUseCaseTests {

    @Test func selectsTorchModeAndReturnsUpdatedSnapshot() async throws {
        let controller = CameraSessionControllerSpy()
        let useCase = SetCameraTorchModeUseCase(cameraSession: controller)

        let snapshot = try await useCase.execute(mode: .on)

        #expect(await controller.operations == [.setTorchMode(.on)])
        #expect(snapshot.torchMode == .on)
    }

    @Test func propagatesTorchSelectionFailure() async {
        let controller = CameraSessionControllerSpy(failure: .setTorchMode(.auto))
        let useCase = SetCameraTorchModeUseCase(cameraSession: controller)

        await #expect(throws: CameraSessionControllerSpyError.failure) {
            try await useCase.execute(mode: .auto)
        }
    }

}
