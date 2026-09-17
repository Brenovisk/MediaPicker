//
//  ImageIOPhotoPreviewLoader.swift
//  MediaPicker
//
//  Created by Breno Lucas on 16/09/26.
//

import Foundation
import ImageIO

/** Downsamples captured files with ImageIO away from the main actor. */
struct ImageIOPhotoPreviewLoader: PhotoPreviewLoading {

    func load(from url: URL, maximumPixelSize: Int) async -> PhotoPreviewImage? {
        await Task.detached(priority: .userInitiated) {
            guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
                return nil
            }

            let options: [CFString: Any] = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: maximumPixelSize
            ]
            guard let image = CGImageSourceCreateThumbnailAtIndex(
                source,
                .zero,
                options as CFDictionary
            ) else {
                return nil
            }
            return PhotoPreviewImage(cgImage: image)
        }.value
    }

}
