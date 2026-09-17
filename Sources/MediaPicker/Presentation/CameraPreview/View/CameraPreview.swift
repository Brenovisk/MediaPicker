//
//  CameraPreview.swift
//  MediaPicker
//
//  Created by Breno Lucas on 09/09/26.
//

#if os(iOS)
import Combine
import SwiftUI
import UIKit

/**
 Displays the live camera feed and accessible photo controls.

 `onCapture` receives a temporary-file result after the user confirms the photo.
 `onCancel` runs after the camera session has closed successfully.
*/
public struct CameraPreview: View {

    @Environment(\.scenePhase) private var scenePhase
    @State private var landscapeSide = CameraLandscapeSide.current
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
                    image: viewModel.capturedPhotoPreview,
                    onRetake: viewModel.recapturePhoto,
                    onConfirm: confirmPhoto
                )
                .transition(.opacity)
                .task(id: capturedMedia.id) {
                    await viewModel.loadCapturedPhotoPreview()
                }
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
        .onAppear {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
            updateLandscapeSide()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIDevice.orientationDidChangeNotification
            )
        ) { _ in
            updateLandscapeSide()
        }
        .onDisappear {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
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
        GeometryReader { proxy in
            let orientation = CameraPreviewOrientation(
                size: proxy.size,
                landscapeSide: landscapeSide
            )

            CameraPreviewLayout(orientation: orientation) {
                topBar(
                    placement: orientation.topBarPlacement,
                    rotationDegrees: orientation.controlRotationDegrees
                )

                cameraFeed

                cameraControls(
                    layout: orientation.controlsLayout,
                    rotationDegrees: orientation.controlRotationDegrees
                )
            }
        }
        .background(Color.black.ignoresSafeArea())
    }

    private func topBar(
        placement: CameraPreviewTopBar.Placement,
        rotationDegrees: Double
    ) -> some View {
        CameraPreviewTopBar(
            placement: placement,
            canClose: viewModel.canClose,
            showsPreparationIndicator: viewModel.showsPreparationIndicator,
            rotationDegrees: rotationDegrees,
            onClose: close
        )
    }

    private func cameraControls(
        layout: CameraPreviewControls.Layout,
        rotationDegrees: Double
    ) -> some View {
        CameraPreviewControls(
            layout: layout,
            rotationDegrees: rotationDegrees,
            flashMode: viewModel.flashMode,
            flashAccessibilityLabel: viewModel.flashAccessibilityLabel,
            canChangeFlashMode: viewModel.canChangeFlashMode,
            canCapturePhoto: viewModel.canCapturePhoto,
            canSwitchCamera: viewModel.canSwitchCamera,
            onFlash: changeFlashMode,
            onCapture: capturePhoto,
            onSwitchCamera: switchCamera
        )
    }

    private func updateLandscapeSide() {
        guard let side = CameraLandscapeSide(
            deviceOrientation: UIDevice.current.orientation
        ) else { return }
        landscapeSide = side
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

private extension CameraLandscapeSide {

    @MainActor
    static var current: CameraLandscapeSide {
        CameraLandscapeSide(deviceOrientation: UIDevice.current.orientation) ?? .left
    }

    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .landscapeLeft:
            self = .left
        case .landscapeRight:
            self = .right
        default:
            return nil
        }
    }

}
#endif
