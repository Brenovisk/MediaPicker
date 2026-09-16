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
            CameraShutterButtonLabel()
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

private struct CameraShutterButtonLabel: View {

    var body: some View {
        if #available(iOS 26.0, *) {
            shutter
                .glassEffect(.regular.interactive(), in: Circle())
        } else {
            shutter
                .background(.ultraThinMaterial, in: Circle())
        }
    }

    private var shutter: some View {
        Circle()
            .fill(.white.opacity(0.96))
            .padding(CameraPreviewConstants.Layout.shutterInnerInset)
            .overlay {
                Circle().stroke(.white.opacity(0.9), lineWidth: 3)
            }
            .frame(
                width: CameraPreviewConstants.Layout.shutterSize,
                height: CameraPreviewConstants.Layout.shutterSize
            )
            .contentShape(Circle())
    }

}
#endif
