//
//  CameraPreviewViewModel+PhotoControls.swift
//  MediaPicker
//
//  Created by Breno Lucas on 14/09/26.
//

#if os(iOS)
import SwiftUI

/** Keeps photo-control state and actions separate from preview lifecycle logic. */
extension CameraPreviewViewModel {

    var canSwitchCamera: Bool {
        controlsAreReady && isReviewingPhoto == false
    }

    var canCapturePhoto: Bool {
        controlsAreReady && isPhotoCaptureAvailable && isReviewingPhoto == false
    }

    var canChangeFlashMode: Bool {
        controlsAreReady
            && lightingCapabilities.flashModes.count > 1
            && isReviewingPhoto == false
    }

    var canClose: Bool {
        isCapturingPhoto == false && isSwitchingCamera == false
    }

    var isReviewingPhoto: Bool {
        capturedMedia != nil
    }

    var showsPreparationIndicator: Bool {
        isOpeningCamera || cameraState == .preparing
    }

    var flashAccessibilityLabel: String {
        switch flashMode {
        case .off:
            MediaPickerConstants.Text.flashOff.value
        case .on:
            MediaPickerConstants.Text.flashOn.value
        case .auto:
            MediaPickerConstants.Text.flashAuto.value
        }
    }

    func capturePhoto() async throws -> CapturedMedia {
        guard canCapturePhoto else {
            throw MediaPickerError.photoCaptureFailed
        }

        isCapturingPhoto = true
        captureFeedbackTrigger += 1
        showShutterFeedback()
        defer { isCapturingPhoto = false }

        let media = try await capturePhotoUseCase.execute(
            format: photoOutputFormat,
            rotationAngle: previewSurface.rotationAngles.capture
        )
        capturedPhotoPreview = nil
        capturedMedia = media
        return media
    }

    func loadCapturedPhotoPreview() async {
        guard let media = capturedMedia else { return }

        let preview = await loadPhotoPreviewUseCase.execute(
            from: media.contentURL,
            maximumPixelSize: CameraPreviewConstants.Layout.reviewMaximumPixelSize
        )
        guard capturedMedia?.id == media.id else { return }
        capturedPhotoPreview = preview
    }

    func selectNextFlashMode() async throws {
        guard canChangeFlashMode,
              let currentIndex = lightingCapabilities.flashModes.firstIndex(of: flashMode)
        else { return }

        let modes = lightingCapabilities.flashModes
        let nextIndex = modes.index(after: currentIndex)
        let selectedIndex = nextIndex == modes.endIndex ? modes.startIndex : nextIndex
        let snapshot = try await setFlashModeUseCase.execute(mode: modes[selectedIndex])
        apply(snapshot)
    }

    func prepareCameraSwitchFeedback() {
        guard canSwitchCamera else { return }
        switchFeedbackTrigger += 1
    }

    func recapturePhoto() {
        discardCapturedPhoto()
    }

    func confirmCapturedPhoto() -> CapturedMedia? {
        defer {
            capturedMedia = nil
            capturedPhotoPreview = nil
        }
        return capturedMedia
    }

    func discardCapturedPhoto() {
        guard let capturedMedia else { return }
        discardCapturedMediaUseCase.execute(media: capturedMedia)
        self.capturedMedia = nil
        capturedPhotoPreview = nil
    }

    private var controlsAreReady: Bool {
        cameraState == .ready
            && isSwitchingCamera == false
            && isCapturingPhoto == false
    }

    private func showShutterFeedback() {
        shutterFeedbackTask?.cancel()
        shutterFeedbackOpacity = CameraPreviewConstants.Motion.shutterFeedbackOpacity

        shutterFeedbackTask = Task { [weak self] in
            await Task.yield()
            guard Task.isCancelled == false else { return }

            withAnimation(
                .easeOut(duration: CameraPreviewConstants.Motion.shutterFeedbackDuration)
            ) {
                self?.shutterFeedbackOpacity = .zero
            }
        }
    }

}
#endif
