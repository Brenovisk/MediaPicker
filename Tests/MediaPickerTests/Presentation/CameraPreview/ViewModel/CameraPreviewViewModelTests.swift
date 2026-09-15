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

    @Test func preparationIndicatorIsVisibleWhileCameraOpens() async throws {
        let client = CaptureSessionClientSpy(operationDuration: 0.05)
        let service = CaptureSessionService(operations: client.operations)
        let viewModel = CameraPreviewViewModel(
            initialPosition: .back,
            dependencies: .make(cameraSession: service)
        )

        let opening = Task { try await viewModel.open() }
        await Task.yield()

        #expect(viewModel.showsPreparationIndicator)

        try await opening.value
        #expect(viewModel.showsPreparationIndicator == false)
    }

    @Test func photoControlsRequireReadySessionAndPhotoOutput() async throws {
        let unavailableClient = CaptureSessionClientSpy()
        let unavailableService = CaptureSessionService(
            operations: unavailableClient.operations
        )
        let viewModel = CameraPreviewViewModel(
            initialPosition: .back,
            dependencies: .make(cameraSession: unavailableService)
        )

        #expect(viewModel.canCapturePhoto == false)
        try await viewModel.open()
        #expect(viewModel.canCapturePhoto == false)

        let availableClient = CaptureSessionClientSpy(
            photoCapabilities: CameraPhotoOutputCapabilities(
                isAvailable: true,
                flashModes: [.off]
            )
        )
        let availableService = CaptureSessionService(
            operations: availableClient.operations
        )
        let availableViewModel = CameraPreviewViewModel(
            initialPosition: .back,
            dependencies: .make(cameraSession: availableService)
        )

        try await availableViewModel.open()

        #expect(availableViewModel.canCapturePhoto)
    }

    @Test func flashControlCyclesThroughSupportedModes() async throws {
        let capabilities = CameraLightingCapabilities(
            flashModes: [.off, .on, .auto]
        )
        let client = CaptureSessionClientSpy(
            capabilities: [capabilities],
            photoCapabilities: CameraPhotoOutputCapabilities(
                isAvailable: true,
                flashModes: capabilities.flashModes
            )
        )
        let service = CaptureSessionService(operations: client.operations)
        let viewModel = CameraPreviewViewModel(
            initialPosition: .back,
            dependencies: .make(cameraSession: service)
        )
        try await viewModel.open()

        try await viewModel.selectNextFlashMode()
        #expect(viewModel.flashMode == .on)
        #expect(viewModel.flashAccessibilityLabel == "Flash on")

        try await viewModel.selectNextFlashMode()
        #expect(viewModel.flashMode == .auto)

        try await viewModel.selectNextFlashMode()
        #expect(viewModel.flashMode == .off)
    }

    @Test func captureUsesConfiguredFormatAndDisablesConcurrentControls() async throws {
        let client = CaptureSessionClientSpy(
            operationDuration: 0.05,
            photoCapabilities: CameraPhotoOutputCapabilities(
                isAvailable: true,
                flashModes: [.off]
            )
        )
        let service = CaptureSessionService(operations: client.operations)
        let viewModel = CameraPreviewViewModel(
            initialPosition: .back,
            photoOutputFormat: .png,
            dependencies: .make(cameraSession: service)
        )
        try await viewModel.open()

        let capture = Task { try await viewModel.capturePhoto() }
        await Task.yield()

        #expect(viewModel.isCapturingPhoto)
        #expect(viewModel.canCapturePhoto == false)
        #expect(viewModel.canSwitchCamera == false)
        #expect(viewModel.canClose == false)

        _ = try await capture.value
        #expect(viewModel.isCapturingPhoto == false)
        #expect(client.capturedPhotoFormats == [.png])
    }

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

    @Test func cameraSwitchRefreshesCapabilitiesExposedToUI() async throws {
        let backCapabilities = CameraLightingCapabilities(
            flashModes: [.off, .on],
            torchModes: [.off, .on]
        )
        let client = CaptureSessionClientSpy(
            capabilities: [backCapabilities, .unavailable]
        )
        let service = CaptureSessionService(operations: client.operations)
        let viewModel = CameraPreviewViewModel(
            initialPosition: .back,
            dependencies: .make(cameraSession: service)
        )
        try await viewModel.open()
        #expect(viewModel.lightingCapabilities == backCapabilities)

        try await viewModel.switchCamera()

        #expect(viewModel.lightingCapabilities == .unavailable)
        #expect(viewModel.lightingCapabilities.supportsFlash == false)
        #expect(viewModel.lightingCapabilities.supportsTorch == false)
    }

}
#endif
