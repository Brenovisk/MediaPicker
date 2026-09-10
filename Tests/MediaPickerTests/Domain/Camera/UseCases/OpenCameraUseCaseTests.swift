//
//  OpenCameraUseCaseTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

@testable import MediaPicker
import Testing

struct OpenCameraUseCaseTests {

    @Test func opensRequestedCameraAndReturnsUpdatedSnapshot() async throws {
        let controller = CameraSessionControllerSpy(state: .idle, activePosition: nil)
        let useCase = OpenCameraUseCase(cameraSession: controller)

        let snapshot = try await useCase.execute(position: .front)

        #expect(await controller.operations == [.open(.front)])
        #expect(snapshot.state == .ready)
        #expect(snapshot.position == .front)
    }

    @Test func propagatesOpeningFailure() async {
        let controller = CameraSessionControllerSpy(failure: .open(.back))
        let useCase = OpenCameraUseCase(cameraSession: controller)

        await #expect(throws: CameraSessionControllerSpyError.failure) {
            try await useCase.execute(position: .back)
        }
    }

}
