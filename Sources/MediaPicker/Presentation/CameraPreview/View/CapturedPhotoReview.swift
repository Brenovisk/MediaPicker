//
//  CapturedPhotoReview.swift
//  MediaPicker
//
//  Created by Breno Lucas on 16/09/26.
//

#if os(iOS)
import SwiftUI

/** Displays the captured file until the user confirms it or requests a retake. */
struct CapturedPhotoReview: View {

    let image: PhotoPreviewImage?
    let onRetake: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let image {
                Image(decorative: image.cgImage, scale: 1)
                    .resizable()
                    .scaledToFit()
                    .accessibilityLabel(MediaPickerConstants.Text.capturePhoto.value)
            } else {
                ProgressView()
                    .tint(.white)
            }
        }
        .safeAreaInset(edge: .bottom) {
            controls
        }
    }

    private var controls: some View {
        HStack(spacing: CameraPreviewConstants.Layout.reviewControlsSpacing) {
            reviewButton(
                MediaPickerConstants.Text.retakePhoto.value,
                action: onRetake
            )
            reviewButton(
                MediaPickerConstants.Text.usePhoto.value,
                action: onConfirm
            )
        }
        .padding(.horizontal, CameraPreviewConstants.Layout.horizontalPadding)
        .padding(.bottom, CameraPreviewConstants.Layout.verticalPadding)
    }

    private func reviewButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(minHeight: CameraPreviewConstants.Layout.minimumTapTarget)
                .padding(
                    .horizontal,
                    CameraPreviewConstants.Layout.controlHorizontalPadding
                )
                .background(.ultraThinMaterial, in: Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(CameraControlButtonStyle())
    }

}
#endif
