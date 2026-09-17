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

    enum Layout: Equatable {
        case horizontal
        case vertical
    }

    let layout: Layout
    let rotationDegrees: Double
    let flashMode: CameraFlashMode
    let flashAccessibilityLabel: String
    let canChangeFlashMode: Bool
    let canCapturePhoto: Bool
    let canSwitchCamera: Bool
    let onFlash: () -> Void
    let onCapture: () -> Void
    let onSwitchCamera: () -> Void

    init(
        layout: Layout = .horizontal,
        rotationDegrees: Double = .zero,
        flashMode: CameraFlashMode,
        flashAccessibilityLabel: String,
        canChangeFlashMode: Bool,
        canCapturePhoto: Bool,
        canSwitchCamera: Bool,
        onFlash: @escaping () -> Void,
        onCapture: @escaping () -> Void,
        onSwitchCamera: @escaping () -> Void
    ) {
        self.layout = layout
        self.rotationDegrees = rotationDegrees
        self.flashMode = flashMode
        self.flashAccessibilityLabel = flashAccessibilityLabel
        self.canChangeFlashMode = canChangeFlashMode
        self.canCapturePhoto = canCapturePhoto
        self.canSwitchCamera = canSwitchCamera
        self.onFlash = onFlash
        self.onCapture = onCapture
        self.onSwitchCamera = onSwitchCamera
    }

    var body: some View {
        controlsLayout {
            flashButton
            Spacer(minLength: .zero)
            shutterButton
            Spacer(minLength: .zero)
            switchCameraButton
        }
        .frame(
            maxWidth: layout == .horizontal
                ? CameraPreviewConstants.Layout.controlsMaximumWidth
                : .infinity,
            maxHeight: layout == .vertical ? .infinity : nil
        )
        .padding(.horizontal, CameraPreviewConstants.Layout.horizontalPadding)
        .padding(.vertical, CameraPreviewConstants.Layout.verticalPadding)
    }

    private var controlsLayout: AnyLayout {
        switch layout {
        case .horizontal:
            AnyLayout(
                HStackLayout(spacing: CameraPreviewConstants.Layout.controlsSpacing)
            )
        case .vertical:
            AnyLayout(
                VStackLayout(spacing: CameraPreviewConstants.Layout.controlsSpacing)
            )
        }
    }

    private var flashButton: some View {
        Button(action: onFlash) {
            CameraPreviewConstants.Icon.flash(flashMode).image
                .circularLabelButton()
        }
        .animatedButton()
        .disabled(canChangeFlashMode == false)
        .rotationEffect(.degrees(2 * rotationDegrees))
        .accessibilityLabel(flashAccessibilityLabel)
        .accessibilityValue(flashAccessibilityLabel)
    }

    private var shutterButton: some View {
        Button(action: onCapture) {
            CameraShutterButtonLabel()
        }
        .animatedButton()
        .disabled(canCapturePhoto == false)
        .rotationEffect(.degrees(2 * rotationDegrees))
        .accessibilityLabel(MediaPickerConstants.Text.capturePhoto.value)
    }

    private var switchCameraButton: some View {
        Button(action: onSwitchCamera) {
            CameraPreviewConstants.Icon.switchCamera.image
                .circularLabelButton()
        }
        .animatedButton()
        .disabled(canSwitchCamera == false)
        .rotationEffect(.degrees(2 * rotationDegrees))
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
