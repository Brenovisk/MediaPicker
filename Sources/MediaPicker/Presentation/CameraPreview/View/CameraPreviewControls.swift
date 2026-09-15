//
//  CameraPreviewControls.swift
//  MediaPicker
//
//  Created by Breno Lucas on 14/09/26.
//

#if os(iOS)
import SwiftUI

/** Renders accessible photo controls from state supplied by the preview. */
struct CameraPreviewControls: View {

    let flashMode: CameraFlashMode
    let flashAccessibilityLabel: String
    let canChangeFlashMode: Bool
    let canCapturePhoto: Bool
    let canSwitchCamera: Bool
    let onFlash: () -> Void
    let onCapture: () -> Void
    let onSwitchCamera: () -> Void

    var body: some View {
        HStack(spacing: CameraPreviewConstants.Layout.controlsSpacing) {
            flashButton
            Spacer(minLength: .zero)
            shutterButton
            Spacer(minLength: .zero)
            switchCameraButton
        }
        .padding(.horizontal, CameraPreviewConstants.Layout.horizontalPadding)
        .padding(.vertical, CameraPreviewConstants.Layout.verticalPadding)
        .frame(maxWidth: CameraPreviewConstants.Layout.controlsMaximumWidth)
        .background(.black.opacity(CameraPreviewConstants.Layout.controlsBackgroundOpacity))
        .clipShape(
            RoundedRectangle(
                cornerRadius: CameraPreviewConstants.Layout.controlsCornerRadius,
                style: .continuous
            )
        )
    }

    private var flashButton: some View {
        Button(action: onFlash) {
            CameraPreviewConstants.Icon.flash(flashMode).styledImage
        }
        .buttonStyle(CameraControlButtonStyle())
        .disabled(canChangeFlashMode == false)
        .accessibilityLabel(flashAccessibilityLabel)
        .accessibilityValue(flashAccessibilityLabel)
    }

    private var shutterButton: some View {
        Button(action: onCapture) {
            Circle()
                .fill(.white)
                .padding(CameraPreviewConstants.Layout.shutterInnerInset)
                .overlay {
                    Circle().stroke(.white, lineWidth: 3)
                }
                .frame(
                    width: CameraPreviewConstants.Layout.shutterSize,
                    height: CameraPreviewConstants.Layout.shutterSize
                )
                .contentShape(Circle())
        }
        .buttonStyle(CameraControlButtonStyle())
        .disabled(canCapturePhoto == false)
        .accessibilityLabel(MediaPickerConstants.Text.capturePhoto.value)
    }

    private var switchCameraButton: some View {
        Button(action: onSwitchCamera) {
            CameraPreviewConstants.Icon.switchCamera.styledImage
        }
        .buttonStyle(CameraControlButtonStyle())
        .disabled(canSwitchCamera == false)
        .accessibilityLabel(MediaPickerConstants.Text.switchCamera.value)
    }

}
#endif
