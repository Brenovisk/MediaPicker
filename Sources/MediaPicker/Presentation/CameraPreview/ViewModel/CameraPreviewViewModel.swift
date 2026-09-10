//
//  CameraPreviewViewModel.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

#if os(iOS)
import Observation
import SwiftUI

@MainActor
@Observable
final class CameraPreviewViewModel {

    let service: CaptureSessionService
    let previewSurface: CameraPreviewSurface
    private let initialPosition: CameraPosition
    private(set) var activePosition: CameraPosition
    private(set) var cameraState: CameraState = .idle
    private(set) var isSwitchingCamera = false
    private(set) var previewBlurRadius: CGFloat = .zero
    private(set) var previewOpacity = 1.0
    private(set) var previewRotationDegrees = 0.0

    var canSwitchCamera: Bool {
        cameraState == .ready && isSwitchingCamera == false
    }

    init(
        initialPosition: CameraPosition,
        service: CaptureSessionService = CaptureSessionService(),
        previewSurface: CameraPreviewSurface = CameraPreviewSurface()
    ) {
        self.initialPosition = initialPosition
        activePosition = initialPosition
        self.service = service
        self.previewSurface = previewSurface
    }

    func open() async throws {
        try await service.open(for: initialPosition)
        await synchronizeState()
    }

    func close() async throws {
        try await service.close()
        await synchronizeState()
    }

    func switchCamera() async throws {
        guard canSwitchCamera else { return }

        isSwitchingCamera = true
        defer { isSwitchingCamera = false }

        previewSurface.freezeCurrentFrame()

        do {
            blurFrozenFrame()
            try await Task.sleep(
                for: .seconds(CameraPreviewConstants.Motion.blurDuration)
            )

            async let cameraPosition = service.switchCamera()
            
            completeFrozenFrameFlip()
            try await Task.sleep(
                for: .seconds(CameraPreviewConstants.Motion.flipDuration)
            )

            let newPosition = try await cameraPosition
            let sequenceAfterSwitch = previewSurface.latestFrameSequence
            let isPreviewReady = await previewSurface.waitForFrame(
                after: sequenceAfterSwitch
            )

            guard isPreviewReady else {
                try await restorePreviousCamera()
                throw MediaPickerError.captureSessionSwitchFailed
            }

            activePosition = newPosition
            resetCompletedFlip()
            previewSurface.releaseFrozenFrame()
            revealUpdatedPreview()
            try? await Task.sleep(
                for: .seconds(CameraPreviewConstants.Motion.revealDuration)
            )
            await synchronizeState()
        } catch {
            resetCompletedFlip()
            previewSurface.releaseFrozenFrame()
            revealUpdatedPreview()
            throw error
        }
    }

    func updateSession(for phase: ScenePhase) async throws {
        switch phase {
        case .active:
            try await service.applicationWillEnterForeground()
        case .background:
            try await service.applicationDidEnterBackground()
        case .inactive:
            break
        @unknown default:
            break
        }

        await synchronizeState()
    }

}

// MARK: Helper Methods
extension CameraPreviewViewModel {

    private func blurFrozenFrame() {
        withAnimation(
            .easeIn(duration: CameraPreviewConstants.Motion.blurDuration)
        ) {
            previewBlurRadius = CameraPreviewConstants.Motion.concealedBlurRadius
            previewOpacity = CameraPreviewConstants.Motion.concealedOpacity
        }
    }

    private func completeFrozenFrameFlip() {
        withAnimation(
            .easeInOut(duration: CameraPreviewConstants.Motion.flipDuration)
        ) {
            previewRotationDegrees += CameraPreviewConstants.Motion.fullFlipDegrees
        }
    }

    private func revealUpdatedPreview() {
        withAnimation(
            .easeOut(duration: CameraPreviewConstants.Motion.revealDuration)
        ) {
            previewBlurRadius = .zero
            previewOpacity = 1
        }
    }

    private func resetCompletedFlip() {
        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            previewRotationDegrees = .zero
        }
    }

    private func restorePreviousCamera() async throws {
        _ = try await service.switchCamera()
        _ = await previewSurface.waitForFrame(after: nil)
    }

    private func synchronizeState() async {
        cameraState = await service.state

        if let position = await service.activeCameraPosition {
            activePosition = position
        }
    }

}
#endif
