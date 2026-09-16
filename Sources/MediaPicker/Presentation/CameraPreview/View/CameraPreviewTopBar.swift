//
//  CameraPreviewTopBar.swift
//  MediaPicker
//
//  Created by Breno Lucas on 16/09/26.
//

#if os(iOS)
import SwiftUI

/** Places preparation feedback and cancellation above the preview. */
struct CameraPreviewTopBar: View {

    let canClose: Bool
    let showsPreparationIndicator: Bool
    let onClose: () -> Void

    var body: some View {
        ZStack {
            preparationIndicator

            HStack {
                Spacer()
                closeButton
            }
        }
        .padding(.horizontal, CameraPreviewConstants.Layout.horizontalPadding)
        .padding(.bottom, CameraPreviewConstants.Layout.verticalPadding)
    }

    @ViewBuilder
    private var preparationIndicator: some View {
        if showsPreparationIndicator {
            ProgressView()
                .tint(.white)
                .frame(
                    width: CameraPreviewConstants.Layout.minimumTapTarget,
                    height: CameraPreviewConstants.Layout.minimumTapTarget
                )
                .accessibilityLabel(MediaPickerConstants.Text.preparingCamera.value)
        }
    }

    private var closeButton: some View {
        Button(action: onClose) {
            CameraPreviewConstants.Icon.close.styledImage
        }
        .buttonStyle(CameraControlButtonStyle())
        .disabled(canClose == false)
        .accessibilityLabel(MediaPickerConstants.Text.closeCamera.value)
    }

}
#endif
