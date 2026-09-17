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
    let capturePhotoUseCase: CapturePhotoUseCase
    let loadPhotoPreviewUseCase: LoadPhotoPreviewUseCase
    let discardCapturedMediaUseCase: DiscardCapturedMediaUseCase
    let setFlashModeUseCase: SetCameraFlashModeUseCase
    private let setTorchModeUseCase: SetCameraTorchModeUseCase

    private let initialPosition: CameraPosition
    let photoOutputFormat: PhotoOutputFormat
    private var sessionUpdatesTask: Task<Void, Never>?
    var shutterFeedbackTask: Task<Void, Never>?
    private(set) var activePosition: CameraPosition
    private(set) var cameraState: CameraState = .idle
    private(set) var isPhotoCaptureAvailable = false
    private(set) var lightingCapabilities: CameraLightingCapabilities = .unavailable
    private(set) var flashMode: CameraFlashMode = .off
    private(set) var torchMode: CameraTorchMode = .off
    private(set) var isOpeningCamera = false
    private(set) var isSwitchingCamera = false
    var isCapturingPhoto = false
    var shutterFeedbackOpacity = 0.0
    var captureFeedbackTrigger = 0
    var switchFeedbackTrigger = 0
    var capturedMedia: CapturedMedia?
    var capturedPhotoPreview: PhotoPreviewImage?

    private(set) var previewBlurRadius: CGFloat = .zero
    private(set) var privacyBlurRadius: CGFloat = .zero
    private(set) var previewOpacity = 1.0
    private(set) var previewRotationDegrees = 0.0

    var displayedPreviewBlurRadius: CGFloat {
        max(previewBlurRadius, privacyBlurRadius)
    }

    init(
        initialPosition: CameraPosition,
        photoOutputFormat: PhotoOutputFormat = .jpeg,
        dependencies: CameraPreviewDependencies? = nil
    ) {
        let dependencies = dependencies ?? .live()
        self.initialPosition = initialPosition
        self.photoOutputFormat = photoOutputFormat
        activePosition = initialPosition
        previewSession = dependencies.previewSession
        previewSurface = dependencies.previewSurface

        openCameraUseCase = dependencies.openCamera
        closeCameraUseCase = dependencies.closeCamera
        updateCameraSessionUseCase = dependencies.updateCameraSession
        switchCameraUseCase = dependencies.switchCamera
        capturePhotoUseCase = dependencies.capturePhoto
        loadPhotoPreviewUseCase = dependencies.loadPhotoPreview
        discardCapturedMediaUseCase = dependencies.discardCapturedMedia
        setFlashModeUseCase = dependencies.setFlashMode
        setTorchModeUseCase = dependencies.setTorchMode
    }

    func open() async throws {
        guard isOpeningCamera == false else { return }

        isOpeningCamera = true
        defer { isOpeningCamera = false }
        observeSessionUpdates()

        do {
            let snapshot = try await openCameraUseCase.execute(position: initialPosition)
            apply(snapshot)
        } catch {
            stopObservingSessionUpdates()
            throw error
        }
    }

    func close() async throws {
        discardCapturedPhoto()
        stopObservingSessionUpdates()
        let snapshot = try await closeCameraUseCase.execute()
        apply(snapshot)
    }

    func switchCamera() async throws {
        guard canSwitchCamera else { return }

        beginCameraSwitch()
        defer { endCameraSwitch() }

        do {
            try await prepareFrozenFrame()
            let snapshot = try await switchCameraDuringFlip()
            await presentNewPreview(using: snapshot)
        } catch {
            cancelCameraSwitchTransition()
            throw error
        }
    }

    func setTorchMode(_ mode: CameraTorchMode) async throws {
        let snapshot = try await setTorchModeUseCase.execute(mode: mode)
        apply(snapshot)
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

    // MARK: State

    func apply(_ snapshot: CameraSessionSnapshot) {
        cameraState = snapshot.state
        isPhotoCaptureAvailable = snapshot.canCapturePhoto
        lightingCapabilities = snapshot.lightingCapabilities
        flashMode = snapshot.flashMode
        torchMode = snapshot.torchMode

        if let position = snapshot.position {
            activePosition = position
        }
    }

}

// MARK: Helper Methods
extension CameraPreviewViewModel {

    // MARK: Session Observation

    private func observeSessionUpdates() {
        guard sessionUpdatesTask == nil else { return }

        sessionUpdatesTask = Task { [weak self, updateCameraSessionUseCase] in
            let updates = await updateCameraSessionUseCase.observe()

            for await snapshot in updates where Task.isCancelled == false {
                self?.apply(snapshot)
            }
        }
    }

    private func stopObservingSessionUpdates() {
        sessionUpdatesTask?.cancel()
        sessionUpdatesTask = nil
    }

    // MARK: Privacy

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

    // MARK: Camera Switch Transition

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

    private func switchCameraDuringFlip() async throws -> CameraSessionSnapshot {
        async let snapshot = switchCameraUseCase.execute()

        completeFrozenFrameFlip()
        try await Task.sleep(
            for: .seconds(CameraPreviewConstants.Motion.flipDuration)
        )

        return try await snapshot
    }

    private func presentNewPreview(using snapshot: CameraSessionSnapshot) async {
        apply(snapshot)
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

}
#endif
