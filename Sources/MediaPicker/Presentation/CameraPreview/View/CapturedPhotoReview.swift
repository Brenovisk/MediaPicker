//
//  CapturedPhotoReview.swift
//  MediaPicker
//
//  Created by Breno Lucas on 16/09/26.
//

#if os(iOS)
import ImageIO
import SwiftUI
import UIKit

/** Displays the captured file until the user confirms it or requests a retake. */
struct CapturedPhotoReview: View {

    @GestureState private var hidesControls = false
    @State private var image: UIImage?
    let media: CapturedMedia
    let onRetake: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            if let image {
                reviewBackground(image)

                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .accessibilityLabel(MediaPickerConstants.Text.capturePhoto.value)

                controls
                    .opacity(hidesControls ? .zero : 1)
                    .allowsHitTesting(hidesControls == false)
                    .animation(
                        .easeOut(
                            duration: CameraPreviewConstants.Motion
                                .reviewControlsVisibilityDuration
                        ),
                        value: hidesControls
                    )
            } else {
                Color.black.ignoresSafeArea()

                ProgressView()
                    .tint(.white)
            }
        }
        .task(id: media.id) {
            image = await CapturedPhotoReviewImageLoader.load(from: media.contentURL)
        }
        .simultaneousGesture(reviewLongPressGesture)
    }

    private func reviewBackground(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .blur(radius: CameraPreviewConstants.Layout.reviewBackgroundBlurRadius)
            .overlay {
                Color.black.opacity(
                    CameraPreviewConstants.Layout.reviewBackgroundOpacity
                )
            }
            .ignoresSafeArea()
    }

    private var controls: some View {
        VStack {
            Spacer(minLength: .zero)

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
    }

    private var reviewLongPressGesture: some Gesture {
        LongPressGesture(
            minimumDuration: CameraPreviewConstants.Motion.reviewLongPressDuration
        )
        .sequenced(before: DragGesture(minimumDistance: .zero))
        .updating($hidesControls) { value, state, _ in
            guard case .second(true, _) = value else { return }
            state = true
        }
    }

    private func reviewButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: CameraPreviewConstants.Layout.minimumTapTarget)
            .padding(.horizontal, CameraPreviewConstants.Layout.controlHorizontalPadding)
            .background(.ultraThinMaterial, in: Capsule())
            .buttonStyle(CameraControlButtonStyle())
    }

}

private enum CapturedPhotoReviewImageLoader {

    static func load(from url: URL) async -> UIImage? {
        let result = await Task.detached(priority: .userInitiated) {
            SendableImage(image: downsampledImage(from: url))
        }.value
        return result.image
    }

    private static func downsampledImage(from url: URL) -> UIImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return UIImage(contentsOfFile: url.path)
        }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize:
                CameraPreviewConstants.Layout.reviewMaximumPixelSize
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(
            source,
            .zero,
            options as CFDictionary
        ) else {
            return UIImage(contentsOfFile: url.path)
        }
        return UIImage(cgImage: image)
    }

}

private struct SendableImage: @unchecked Sendable {

    let image: UIImage?

}
#endif
