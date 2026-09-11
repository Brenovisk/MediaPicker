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

        let media = try await useCase.execute(format: .png)

        #expect(media.mediaType == .photo)
        #expect(media.source == .camera)
        #expect(await controller.operations == [.capturePhoto(.png)])
    }

    @Test func propagatesCaptureFailure() async {
        let controller = CameraSessionControllerSpy(failure: .capturePhoto(.jpeg))
        let useCase = CapturePhotoUseCase(cameraSession: controller)

        await #expect(throws: CameraSessionControllerSpyError.failure) {
            try await useCase.execute(format: .jpeg)
        }
    }

}
