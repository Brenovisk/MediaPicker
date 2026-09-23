//
//  CameraPreview.swift
//  MediaPicker
//
//  Created by Breno Lucas on 09/09/26.
//

#if os(iOS)
import Combine
import PhotosUI
import SwiftUI
import UIKit

/**
 Displays the live camera feed and accessible photo controls.

 `onCapture` receives a temporary-file result after the user confirms the photo.
 Pass `controlOptions` to change colors or independently hide Flash, Switch
 Camera, Gallery, and review. Without review, results are delivered immediately.
 `onCancel` runs after the camera session has closed successfully.
*/
public struct CameraPreview: View {

    @Environment(\.scenePhase) private var scenePhase
    @State private var landscapeSide = CameraLandscapeSide.current
    @State private var selectedMediaType: MediaType
    @State private var galleryItem: PhotosPickerItem?
    @State private var showsGalleryError = false
    @State private var viewModel: CameraPreviewViewModel
    private let controlOptions: CameraPreviewControlOptions
    private let onCapture: (CapturedMedia) -> Void
    private let onCancel: () -> Void

    public init(
        position: CameraPosition = .back,
        photoOutputFormat: PhotoOutputFormat = .jpeg,
        controlOptions: CameraPreviewControlOptions = CameraPreviewControlOptions(),
        onCapture: @escaping (CapturedMedia) -> Void = { _ in },
        onCancel: @escaping () -> Void = {}
    ) {
        self.onCapture = onCapture
        self.onCancel = onCancel
        self.controlOptions = controlOptions
        _selectedMediaType = State(initialValue: controlOptions.initialMediaType)
        _viewModel = State(
            initialValue: CameraPreviewViewModel(
                initialPosition: position,
                photoOutputFormat: photoOutputFormat,
                showsReview: controlOptions.showsReview
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
        .onChange(of: galleryItem) { _, item in
            guard let item else { return }
            Task { await selectLibraryPhoto(item) }
        }
        .alert(
            MediaPickerConstants.Text.galleryImportFailed.value,
            isPresented: $showsGalleryError
        ) {
            Button(MediaPickerConstants.Text.dismiss.value, role: .cancel) {}
        }
    }

    private var liveCamera: some View {
        GeometryReader { proxy in
            let orientation = CameraPreviewOrientation(
                size: proxy.size,
                landscapeSide: landscapeSide
            )

            CameraPreviewLayout(
                orientation: orientation,
                showsTopBar: controlOptions.showsFlash
                    || controlOptions.showsSwitchCamera
                    || viewModel.showsPreparationIndicator,
                showsMediaSelector: controlOptions.showsMediaSelector
            ) {
                topBar(orientation: orientation)

                cameraFeed

                cameraControls(orientation: orientation)
            }

        }
        .background(Color.black.ignoresSafeArea())
    }

    private func topBar(
        orientation: CameraPreviewOrientation
    ) -> some View {
        CameraPreviewTopBar(
            orientation: orientation,
            options: controlOptions,
            flashMode: viewModel.flashMode,
            flashAccessibilityLabel: viewModel.flashAccessibilityLabel,
            canChangeFlashMode: viewModel.canChangeFlashMode
                && selectedMediaType == .photo,
            canSwitchCamera: viewModel.canSwitchCamera,
            showsPreparationIndicator: viewModel.showsPreparationIndicator,
            onFlash: changeFlashMode,
            onSwitchCamera: switchCamera
        )
    }

    private func cameraControls(
        orientation: CameraPreviewOrientation
    ) -> some View {
        CameraPreviewControls(
            orientation: orientation,
            options: controlOptions,
            canClose: viewModel.canClose,
            canCapturePhoto: viewModel.canCapturePhoto,
            canSelectLibraryPhoto: viewModel.canSelectLibraryPhoto,
            onClose: close,
            onCapture: capturePhoto,
            selectedMediaType: $selectedMediaType,
            galleryItem: $galleryItem
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
        .ignoresSafeArea()
    }

}

extension CameraPreview {

    private func capturePhoto() {
        guard viewModel.canCapturePhoto,
              controlOptions.canCapturePhoto(in: selectedMediaType),
              let previewFraming = viewModel.previewSurface.captureFraming
        else { return }
        let rotationAngle = viewModel.previewSurface.rotationAngles.capture

        Task {
            guard let media = try? await viewModel.capturePhoto(
                previewFraming: previewFraming,
                rotationAngle: rotationAngle
            ) else { return }
            if controlOptions.showsReview == false {
                deliver(media)
            }
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
        deliver(media)
    }

    private func selectLibraryPhoto(_ item: PhotosPickerItem) async {
        defer { galleryItem = nil }

        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                throw MediaPickerError.photoLibraryLoadingFailed
            }
            let media = try viewModel.selectLibraryPhoto(data)
            if controlOptions.showsReview == false {
                deliver(media)
            }
        } catch {
            showsGalleryError = true
        }
    }

    private func deliver(_ media: CapturedMedia) {
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
