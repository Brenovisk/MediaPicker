//
//  CameraPreviewViewModelTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

#if os(iOS)
@testable import MediaPicker
import SwiftUI
import Testing

@MainActor
struct CameraPreviewViewModelTests {

    @Test func activeCameraPositionUpdatesAfterSwitch() async throws {
        let client = CaptureSessionClientSpy()
        let service = CaptureSessionService(operations: client.operations)
        let viewModel = CameraPreviewViewModel(
            initialPosition: .back,
            dependencies: .make(cameraSession: service)
        )
        try await viewModel.open()

        try await viewModel.switchCamera()

        #expect(viewModel.activePosition == .front)
        #expect(viewModel.canSwitchCamera)
        #expect(viewModel.previewBlurRadius == .zero)
        #expect(viewModel.previewOpacity == 1)
        #expect(viewModel.previewRotationDegrees == .zero)
    }

    @Test func switchControlIsDisabledWhileCameraIsSuspended() async throws {
        let client = CaptureSessionClientSpy()
        let service = CaptureSessionService(operations: client.operations)
        let viewModel = CameraPreviewViewModel(
            initialPosition: .back,
            dependencies: .make(cameraSession: service)
        )
        try await viewModel.open()

        try await viewModel.updateSession(for: .background)

        #expect(viewModel.cameraState == .suspended)
        #expect(viewModel.canSwitchCamera == false)
        #expect(
            viewModel.privacyBlurRadius == CameraPreviewConstants.Motion.privacyBlurRadius
        )
    }

    @Test func privacyBlurIsRemovedAfterReturningToForeground() async throws {
        let client = CaptureSessionClientSpy()
        let service = CaptureSessionService(operations: client.operations)
        let viewModel = CameraPreviewViewModel(
            initialPosition: .back,
            dependencies: .make(cameraSession: service)
        )
        try await viewModel.open()
        try await viewModel.updateSession(for: .background)

        try await viewModel.updateSession(for: .active)

        #expect(viewModel.cameraState == .ready)
        #expect(viewModel.privacyBlurRadius == .zero)
    }

}
#endif
