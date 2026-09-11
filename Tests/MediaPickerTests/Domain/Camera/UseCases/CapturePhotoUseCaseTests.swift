//
//  CapturePhotoUseCaseTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

@testable import MediaPicker
import Testing

struct CapturePhotoUseCaseTests {

    @Test func capturesPhotoThroughSessionContract() async throws {
        let controller = CameraSessionControllerSpy()
        let useCase = CapturePhotoUseCase(cameraSession: controller)

        let request = try await useCase.execute()

        #expect(request.id == 1)
        #expect(await controller.operations == [.capturePhoto])
    }

    @Test func propagatesCaptureFailure() async {
        let controller = CameraSessionControllerSpy(failure: .capturePhoto)
        let useCase = CapturePhotoUseCase(cameraSession: controller)

        await #expect(throws: CameraSessionControllerSpyError.failure) {
            try await useCase.execute()
        }
    }

}
