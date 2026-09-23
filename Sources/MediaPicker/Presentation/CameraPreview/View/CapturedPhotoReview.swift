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
        GeometryReader { proxy in
            let isLandscape = proxy.size.width > proxy.size.height

            content
                .overlay(alignment: isLandscape ? .trailing : .bottom) {
                    controls(isLandscape: isLandscape)
                }
                .background {
                    background
                        .ignoresSafeArea()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        ZStack {
            if let image {
                Image(decorative: image.cgImage, scale: 1)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityLabel(MediaPickerConstants.Text.capturePhoto.value)
            } else {
                ProgressView()
                    .tint(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var background: some View {
        ZStack {
            Color.black

            if let image {
                Image(decorative: image.cgImage, scale: 1)
                    .resizable()
                    .scaledToFill()
                    .blur(
                        radius: CameraPreviewConstants.Layout
                            .reviewBackgroundImageRadiusBlur
                    )
                    .overlay {
                        Color.black.opacity(
                            CameraPreviewConstants.Layout.reviewBackgroundImageOpacity
                        )
                    }
                    .ignoresSafeArea()
            }
        }
        .clipped()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func controls(isLandscape: Bool) -> some View {
        let layout = controlsLayout(isLandscape: isLandscape)

        return layout {
            if isLandscape {
                confirmButton
                Spacer(minLength: .zero)
                retakeButton
            } else {
                retakeButton
                Spacer(minLength: .zero)
                confirmButton
            }
        }
        .frame(
            maxWidth: isLandscape ? nil : .infinity,
            maxHeight: isLandscape ? .infinity : nil
        )
        .padding(.horizontal, CameraPreviewConstants.Layout.horizontalPadding)
        .padding(.vertical, CameraPreviewConstants.Layout.verticalPadding)
    }

    private func controlsLayout(isLandscape: Bool) -> AnyLayout {
        if isLandscape {
            AnyLayout(
                VStackLayout(spacing: CameraPreviewConstants.Layout.reviewControlsSpacing)
            )
        } else {
            AnyLayout(
                HStackLayout(spacing: CameraPreviewConstants.Layout.reviewControlsSpacing)
            )
        }
    }

    private var retakeButton: some View {
        Button(action: onRetake) {
            CameraPreviewConstants.Icon.retakePhoto.image
                .circularLabelButton()
        }
        .animatedButton()
        .accessibilityLabel(MediaPickerConstants.Text.retakePhoto.value)
    }

    private var confirmButton: some View {
        Button(action: onConfirm) {
            CameraPreviewConstants.Icon.confirmPhoto.image
                .circularLabelButton(
                    foregroundColor: .black,
                    backgroundColor: .white,
                    backgroundOpacity: 1,
                    usesLiquidGlass: false
                )
        }
        .animatedButton()
        .accessibilityLabel(MediaPickerConstants.Text.usePhoto.value)
    }

}
#endif
