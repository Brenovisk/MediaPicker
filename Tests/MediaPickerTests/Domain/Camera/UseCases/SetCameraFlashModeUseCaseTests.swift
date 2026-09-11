//
//  SetCameraFlashModeUseCaseTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

@testable import MediaPicker
import Testing

struct SetCameraFlashModeUseCaseTests {

    @Test func selectsFlashModeAndReturnsUpdatedSnapshot() async throws {
        let controller = CameraSessionControllerSpy()
        let useCase = SetCameraFlashModeUseCase(cameraSession: controller)

        let snapshot = try await useCase.execute(mode: .auto)

        #expect(await controller.operations == [.setFlashMode(.auto)])
        #expect(snapshot.flashMode == .auto)
    }

    @Test func propagatesFlashSelectionFailure() async {
        let controller = CameraSessionControllerSpy(failure: .setFlashMode(.on))
        let useCase = SetCameraFlashModeUseCase(cameraSession: controller)

        await #expect(throws: CameraSessionControllerSpyError.failure) {
            try await useCase.execute(mode: .on)
        }
    }

}
