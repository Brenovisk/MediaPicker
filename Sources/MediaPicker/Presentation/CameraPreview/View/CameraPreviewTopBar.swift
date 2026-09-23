//
//  CameraPreviewTopBar.swift
//  MediaPicker
//
//  Created by Breno Lucas on 16/09/26.
//

#if os(iOS)
import SwiftUI

/** Keeps flash and camera switching in a compact, accessible control area. */
struct CameraPreviewTopBar: View {

    let orientation: CameraPreviewOrientation
    let options: CameraPreviewControlOptions
    let flashMode: CameraFlashMode
    let flashAccessibilityLabel: String
    let canChangeFlashMode: Bool
    let canSwitchCamera: Bool
    let showsPreparationIndicator: Bool
    let onFlash: () -> Void
    let onSwitchCamera: () -> Void

    var body: some View {
        Group {
            if orientation == .portrait {
                HStack(spacing: 12) { content }
            } else {
                VStack(spacing: 12) { content }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(options.backgroundColor.opacity(0.32))
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private var content: some View {
        if options.showsFlash {
            Button(action: onFlash) {
                CameraControlIcon(
                    systemName: CameraPreviewConstants.Icon.flash(flashMode).systemName
                )
                    .topCameraControlLabel(
                        foregroundColor: flashMode == .off
                            ? options.foregroundColor
                            : .yellow
                    )
            }
            .animatedButton()
            .disabled(canChangeFlashMode == false)
            .accessibilityLabel(flashAccessibilityLabel)
        }

        if options.showsSwitchCamera {
            Button(action: onSwitchCamera) {
                CameraControlIcon(
                    systemName: CameraPreviewConstants.Icon.switchCamera.systemName
                )
                    .topCameraControlLabel(
                        foregroundColor: options.foregroundColor
                    )
            }
            .animatedButton()
            .disabled(canSwitchCamera == false)
            .accessibilityLabel(MediaPickerConstants.Text.switchCamera.value)
        }

        if showsPreparationIndicator {
            ProgressView()
                .tint(options.foregroundColor)
                .frame(
                    width: CameraPreviewConstants.Layout.topControlSize,
                    height: CameraPreviewConstants.Layout.topControlSize
                )
                .accessibilityLabel(MediaPickerConstants.Text.preparingCamera.value)
        }
    }

}
#endif
