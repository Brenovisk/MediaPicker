//
//  CaptureSessionPhotoOrientationTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 14/09/26.
//

@testable import MediaPicker
import Testing

struct CaptureSessionPhotoOrientationTests {

    private let photoOutput = CameraPhotoOutputCapabilities(
        isAvailable: true,
        flashModes: [.off]
    )

    @Test func backCameraUsesCaptureAngleWithoutMirroring() async throws {
        let client = CaptureSessionClientSpy(photoCapabilities: photoOutput)
        let service = CaptureSessionService(operations: client.operations)
        try await service.open(for: .back)

        _ = try await service.capturePhoto(format: .jpeg, rotationAngle: 90)

        #expect(client.photoCaptureOptions.first?.rotationAngle == 90)
        #expect(client.photoCaptureOptions.first?.isMirrored == false)
    }

    @Test func frontCameraUsesCaptureAngleWithMirroring() async throws {
        let client = CaptureSessionClientSpy(photoCapabilities: photoOutput)
        let service = CaptureSessionService(operations: client.operations)
        try await service.open(for: .front)

        _ = try await service.capturePhoto(format: .jpeg, rotationAngle: 270)

        #expect(client.photoCaptureOptions.first?.rotationAngle == 270)
        #expect(client.photoCaptureOptions.first?.isMirrored == true)
    }

}
