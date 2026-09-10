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

    let previewSession: CaptureSessionReference?
    let previewSurface: CameraPreviewSurface

    private let openCameraUseCase: OpenCameraUseCase
    private let closeCameraUseCase: CloseCameraUseCase
    private let updateCameraSessionUseCase: UpdateCameraSessionUseCase
    private let switchCameraUseCase: SwitchCameraUseCase

    private let initialPosition: CameraPosition
    private(set) var activePosition: CameraPosition
    private(set) var cameraState: CameraState = .idle
    private(set) var isSwitchingCamera = false

    private(set) var previewBlurRadius: CGFloat = .zero
    private(set) var privacyBlurRadius: CGFloat = .zero
    private(set) var previewOpacity = 1.0
    private(set) var previewRotationDegrees = 0.0

    var canSwitchCamera: Bool {
        cameraState == .ready && isSwitchingCamera == false
    }

    var displayedPreviewBlurRadius: CGFloat {
        max(previewBlurRadius, privacyBlurRadius)
    }

    init(
        initialPosition: CameraPosition,
        dependencies: CameraPreviewDependencies = .live()
    ) {
        self.initialPosition = initialPosition
        activePosition = initialPosition
        previewSession = dependencies.previewSession
        previewSurface = dependencies.previewSurface

        openCameraUseCase = dependencies.openCamera
        closeCameraUseCase = dependencies.closeCamera
        updateCameraSessionUseCase = dependencies.updateCameraSession
        switchCameraUseCase = dependencies.switchCamera
    }

    func open() async throws {
        let snapshot = try await openCameraUseCase.execute(position: initialPosition)
        apply(snapshot)
    }

    func close() async throws {
        let snapshot = try await closeCameraUseCase.execute()
        apply(snapshot)
    }

    func switchCamera() async throws {
        guard canSwitchCamera else { return }

        beginCameraSwitch()
        defer { endCameraSwitch() }

        do {
            try await prepareFrozenFrame()
            let newPosition = try await switchCameraDuringFlip()
            await presentNewPreview(at: newPosition)
        } catch {
            cancelCameraSwitchTransition()
            throw error
        }
    }

    func updateSession(for phase: ScenePhase) async throws {
        switch phase {
        case .active:
            let snapshot = try await updateCameraSessionUseCase.execute(
                event: .enteredForeground
            )
            apply(snapshot)
            revealPreviewAfterPrivacy()
        case .background:
            concealPreviewForPrivacy()
            let snapshot = try await updateCameraSessionUseCase.execute(
                event: .enteredBackground
            )
            apply(snapshot)
        case .inactive:
            concealPreviewForPrivacy()
        @unknown default:
            concealPreviewForPrivacy()
        }
    }

}

// MARK: Helper Methods
extension CameraPreviewViewModel {

    private func concealPreviewForPrivacy() {
        withAnimation(
            .easeIn(duration: CameraPreviewConstants.Motion.privacyBlurDuration)
        ) {
            privacyBlurRadius = CameraPreviewConstants.Motion.privacyBlurRadius
        }
    }

    private func revealPreviewAfterPrivacy() {
        withAnimation(
            .easeOut(duration: CameraPreviewConstants.Motion.privacyRevealDuration)
        ) {
            privacyBlurRadius = .zero
        }
    }

    private func beginCameraSwitch() {
        isSwitchingCamera = true
        previewSurface.freezeCurrentFrame()
    }

    private func endCameraSwitch() {
        isSwitchingCamera = false
    }

    private func prepareFrozenFrame() async throws {
        blurFrozenFrame()
        try await Task.sleep(
            for: .seconds(CameraPreviewConstants.Motion.blurDuration)
        )
    }

    private func switchCameraDuringFlip() async throws -> CameraPosition {
        async let cameraPosition = switchCameraUseCase.execute()

        completeFrozenFrameFlip()
        try await Task.sleep(
            for: .seconds(CameraPreviewConstants.Motion.flipDuration)
        )

        return try await cameraPosition
    }

    private func presentNewPreview(at position: CameraPosition) async {
        activePosition = position
        finishCameraSwitchTransition()
        try? await Task.sleep(
            for: .seconds(CameraPreviewConstants.Motion.revealDuration)
        )
    }

    private func finishCameraSwitchTransition() {
        resetCompletedFlip()
        previewSurface.releaseFrozenFrame()
        revealUpdatedPreview()
    }

    private func cancelCameraSwitchTransition() {
        finishCameraSwitchTransition()
    }

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

    private func apply(_ snapshot: CameraSessionSnapshot) {
        cameraState = snapshot.state

        if let position = snapshot.position {
            activePosition = position
        }
    }

}
#endif
