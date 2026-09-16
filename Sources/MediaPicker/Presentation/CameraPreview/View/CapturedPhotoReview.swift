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

    @State private var image: UIImage?
    let media: CapturedMedia
    let onRetake: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .accessibilityLabel(MediaPickerConstants.Text.capturePhoto.value)
            } else {
                ProgressView()
                    .tint(.white)
            }
        }
        .task(id: media.id) {
            image = await CapturedPhotoReviewImageLoader.load(from: media.contentURL)
        }
        .safeAreaInset(edge: .bottom) {
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
            .padding(.vertical, CameraPreviewConstants.Layout.verticalPadding)
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
