//
//  CameraPreview.swift
//  MediaPicker
//
//  Created by Breno Lucas on 09/09/26.
//

#if os(iOS)
import SwiftUI

/**
 Displays the live camera feed and accessible photo controls.

 `onCapture` receives a temporary-file result after the user confirms the photo.
 `onCancel` runs after the camera session has closed successfully.
*/
public struct CameraPreview: View {

    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel: CameraPreviewViewModel
    private let onCapture: (CapturedMedia) -> Void
    private let onCancel: () -> Void

    public init(
        position: CameraPosition = .back,
        photoOutputFormat: PhotoOutputFormat = .jpeg,
        onCapture: @escaping (CapturedMedia) -> Void = { _ in },
        onCancel: @escaping () -> Void = {}
    ) {
        self.onCapture = onCapture
        self.onCancel = onCancel
        _viewModel = State(
            initialValue: CameraPreviewViewModel(
                initialPosition: position,
                photoOutputFormat: photoOutputFormat
            )
        )
    }

    public var body: some View {
        ZStack {
            liveCamera

            if let capturedMedia = viewModel.capturedMedia {
                CapturedPhotoReview(
                    media: capturedMedia,
                    onRetake: viewModel.recapturePhoto,
                    onConfirm: confirmPhoto
                )
                .transition(.opacity)
            }
        }
        .animation(
            .easeOut(duration: CameraPreviewConstants.Motion.reviewTransitionDuration),
            value: viewModel.isReviewingPhoto
        )
        .sensoryFeedback(
            .impact(weight: .medium),
            trigger: viewModel.captureFeedbackTrigger
        )
        .sensoryFeedback(
            .impact(weight: .light),
            trigger: viewModel.switchFeedbackTrigger
        )
        .task {
            try? await viewModel.open()
        }
        .onDisappear {
            Task {
                try? await viewModel.close()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            Task {
                try? await viewModel.updateSession(for: phase)
            }
        }
    }

    private var liveCamera: some View {
        ZStack {
            cameraFeed
                .ignoresSafeArea()

            VStack(spacing: .zero) {
                CameraPreviewTopBar(
                    canClose: viewModel.canClose,
                    showsPreparationIndicator: viewModel.showsPreparationIndicator,
                    onClose: close
                )
                .frame(maxWidth: .infinity)

                Spacer(minLength: .zero)

                CameraPreviewControls(
                    flashMode: viewModel.flashMode,
                    flashAccessibilityLabel: viewModel.flashAccessibilityLabel,
                    canChangeFlashMode: viewModel.canChangeFlashMode,
                    canCapturePhoto: viewModel.canCapturePhoto,
                    canSwitchCamera: viewModel.canSwitchCamera,
                    onFlash: changeFlashMode,
                    onCapture: capturePhoto,
                    onSwitchCamera: switchCamera
                )
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var cameraFeed: some View {
        Group {
            if let previewSession = viewModel.previewSession {
                CameraPreviewRepresentable(
                    previewSession: previewSession,
                    cameraPosition: viewModel.activePosition,
                    surface: viewModel.previewSurface
                )
            }
        }
        .blur(radius: viewModel.displayedPreviewBlurRadius)
        .opacity(viewModel.previewOpacity)
        .rotation3DEffect(
            .degrees(viewModel.previewRotationDegrees),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.72
        )
        .overlay {
            Color.white
                .opacity(viewModel.shutterFeedbackOpacity)
                .allowsHitTesting(false)
                .ignoresSafeArea()
        }
    }

}

extension CameraPreview {

    private func capturePhoto() {
        guard viewModel.canCapturePhoto else { return }

        Task {
            _ = try? await viewModel.capturePhoto()
        }
    }

    private func switchCamera() {
        guard viewModel.canSwitchCamera else { return }
        viewModel.prepareCameraSwitchFeedback()

        Task {
            try? await viewModel.switchCamera()
        }
    }

    private func changeFlashMode() {
        Task {
            try? await viewModel.selectNextFlashMode()
        }
    }

    private func close() {
        guard viewModel.canClose else { return }

        Task {
            guard (try? await viewModel.close()) != nil else { return }
            onCancel()
        }
    }

    private func confirmPhoto() {
        guard let media = viewModel.confirmCapturedPhoto() else { return }
        CapturedMediaDebugLogger.logConfirmation(of: media)
        onCapture(media)
    }

}
#endif
