//
//  CameraPreview.swift
//  MediaPicker
//
//  Created by Breno Lucas on 09/09/26.
//

#if os(iOS)
import SwiftUI

/** Displays the live camera feed without exposing AVFoundation session types. */
public struct CameraPreview: View {

    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel: CameraPreviewViewModel

    public init(position: CameraPosition = .back) {
        _viewModel = State(
            initialValue: CameraPreviewViewModel(initialPosition: position)
        )
    }

    public var body: some View {
        Group {
            if let previewSession = viewModel.service.previewSession {
                CameraPreviewRepresentable(
                    previewSession: previewSession,
                    isMirrored: viewModel.activePosition == .front,
                    surface: viewModel.previewSurface
                )
            }
        }
        .blur(radius: viewModel.previewBlurRadius)
        .opacity(viewModel.previewOpacity)
        .rotation3DEffect(
            .degrees(viewModel.previewRotationDegrees),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.72
        )
        .overlay(alignment: .bottomTrailing) {
            switchCameraButton
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

    private var switchCameraButton: some View {
        Button {
            Task {
                try? await viewModel.switchCamera()
            }
        } label: {
            CameraPreviewConstants.Icon.switchCamera.styledImage
        }
        .buttonStyle(CameraSwitchButtonStyle())
        .padding(.horizontal, CameraPreviewConstants.Layout.horizontalPadding)
        .padding(.bottom, CameraPreviewConstants.Layout.bottomPadding)
        .disabled(viewModel.canSwitchCamera == false)
        .accessibilityLabel(MediaPickerConstants.Text.switchCamera.value)
    }

}
#endif
