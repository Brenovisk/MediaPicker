//
//  CloseCameraUseCaseTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

@testable import MediaPicker
import Testing

struct CloseCameraUseCaseTests {

    @Test func closesCameraAndReturnsIdleSnapshot() async throws {
        let controller = CameraSessionControllerSpy()
        let useCase = CloseCameraUseCase(cameraSession: controller)

        let snapshot = try await useCase.execute()

        #expect(await controller.operations == [.close])
        #expect(snapshot.state == .idle)
        #expect(snapshot.position == nil)
    }

    @Test func propagatesClosingFailure() async {
        let controller = CameraSessionControllerSpy(failure: .close)
        let useCase = CloseCameraUseCase(cameraSession: controller)

        await #expect(throws: CameraSessionControllerSpyError.failure) {
            try await useCase.execute()
        }
    }

}
