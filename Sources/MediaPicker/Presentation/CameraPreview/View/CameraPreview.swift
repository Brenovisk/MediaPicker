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

 `onCapture` receives a temporary-file result after a successful photo capture.
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
        .safeAreaInset(edge: .top) {
            topBar
        }
        .safeAreaInset(edge: .bottom) {
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
            .padding(.horizontal, CameraPreviewConstants.Layout.horizontalPadding)
            .padding(.bottom, CameraPreviewConstants.Layout.verticalPadding)
        }
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

    private var topBar: some View {
        HStack(spacing: CameraPreviewConstants.Layout.progressSpacing) {
            Button(action: close) {
                CameraPreviewConstants.Icon.close.styledImage
            }
            .buttonStyle(CameraControlButtonStyle())
            .disabled(viewModel.canClose == false)
            .accessibilityLabel(MediaPickerConstants.Text.closeCamera.value)

            Spacer()

            if viewModel.showsPreparationIndicator {
                ProgressView()
                    .tint(.white)
                    .accessibilityLabel(MediaPickerConstants.Text.preparingCamera.value)
            }
        }
        .padding(.horizontal, CameraPreviewConstants.Layout.horizontalPadding)
        .padding(.top, CameraPreviewConstants.Layout.verticalPadding)
    }

}

extension CameraPreview {

    private func capturePhoto() {
        guard viewModel.canCapturePhoto else { return }

        Task {
            guard let media = try? await viewModel.capturePhoto() else { return }
            onCapture(media)
        }
    }

    private func switchCamera() {
        guard viewModel.canSwitchCamera else { return }

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

}
#endif
