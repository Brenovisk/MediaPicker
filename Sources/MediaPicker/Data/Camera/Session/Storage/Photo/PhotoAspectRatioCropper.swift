//
//  PhotoAspectRatioCropper.swift
//  MediaPicker
//
//  Created by Breno Lucas on 18/09/26.
//

import CoreGraphics
import Foundation
import ImageIO

/** Applies the orientation and visible live-preview crop to a captured photo. */
struct PhotoAspectRatioCropper: Sendable {

    func cropIfNeeded(
        _ source: CGImageSource,
        using framing: CameraPreviewFraming
    ) throws -> CGImage? {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, .zero, nil)
                as? [CFString: Any],
              let pixelWidth = properties[kCGImagePropertyPixelWidth] as? Int,
              let pixelHeight = properties[kCGImagePropertyPixelHeight] as? Int else {
            throw MediaPickerError.photoCaptureFailed
        }

        let orientation = (properties[kCGImagePropertyOrientation] as? NSNumber)?
            .intValue ?? 1
        let rotatesQuarterTurn = [5, 6, 7, 8].contains(orientation)
        let displayWidth = rotatesQuarterTurn ? pixelHeight : pixelWidth
        let displayHeight = rotatesQuarterTurn ? pixelWidth : pixelHeight
        let displayBounds = CGRect(
            x: .zero,
            y: .zero,
            width: displayWidth,
            height: displayHeight
        )
        let cropRect = Self.cropRect(in: displayBounds, framing: framing)
        guard cropRect.size != displayBounds.size else { return nil }

        // Apply EXIF orientation before cropping so portrait and landscape
        // use the same visual center as the live preview.
        let orientedImage = try orientedImage(
            source,
            maximumPixelSize: max(pixelWidth, pixelHeight)
        )
        guard let croppedImage = orientedImage.cropping(to: cropRect) else {
            throw MediaPickerError.photoCaptureFailed
        }
        return croppedImage
    }

    func orientedImage(_ source: CGImageSource) throws -> CGImage {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, .zero, nil)
                as? [CFString: Any],
              let pixelWidth = properties[kCGImagePropertyPixelWidth] as? Int,
              let pixelHeight = properties[kCGImagePropertyPixelHeight] as? Int else {
            throw MediaPickerError.photoCaptureFailed
        }

        return try orientedImage(
            source,
            maximumPixelSize: max(pixelWidth, pixelHeight)
        )
    }

    static func cropRect(
        in bounds: CGRect,
        framing: CameraPreviewFraming
    ) -> CGRect {
        if let normalizedCrop = framing.normalizedCrop {
            let normalizedRect = pixelAlignedCrop(
                normalizedCrop,
                in: bounds
            )
            if normalizedRect.matches(
                aspectRatio: framing.aspectRatio,
                within: bounds
            ) {
                return normalizedRect
            }
        }

        return centeredCrop(in: bounds, aspectRatio: framing.aspectRatio)
    }

    static func centeredCrop(in bounds: CGRect, aspectRatio: Double) -> CGRect {
        let currentRatio = Double(bounds.width / bounds.height)
        let width = currentRatio > aspectRatio
            ? max(1, floor(bounds.height * aspectRatio))
            : bounds.width
        let height = currentRatio < aspectRatio
            ? max(1, floor(bounds.width / aspectRatio))
            : bounds.height

        return CGRect(
            x: bounds.minX + floor((bounds.width - width) / 2),
            y: bounds.minY + floor((bounds.height - height) / 2),
            width: width,
            height: height
        )
    }

    private static func pixelAlignedCrop(
        _ normalizedCrop: CameraNormalizedRect,
        in bounds: CGRect
    ) -> CGRect {
        let minX = bounds.minX + floor(bounds.width * normalizedCrop.originX)
        let minY = bounds.minY + floor(bounds.height * normalizedCrop.originY)
        let maxX = bounds.minX + ceil(
            bounds.width * (normalizedCrop.originX + normalizedCrop.width)
        )
        let maxY = bounds.minY + ceil(
            bounds.height * (normalizedCrop.originY + normalizedCrop.height)
        )

        return CGRect(
            x: minX,
            y: minY,
            width: max(1, maxX - minX),
            height: max(1, maxY - minY)
        ).intersection(bounds)
    }

    private func orientedImage(
        _ source: CGImageSource,
        maximumPixelSize: Int
    ) throws -> CGImage {
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
            throw MediaPickerError.photoCaptureFailed
        }
        return image
    }

}

private extension CGRect {

    func matches(aspectRatio: Double, within bounds: CGRect) -> Bool {
        guard width > .zero, height > .zero else { return false }
        let actualRatio = Double(width / height)
        let pixelTolerance = max(1 / Double(bounds.width), 1 / Double(bounds.height))
        return abs(actualRatio - aspectRatio) <= max(0.01, pixelTolerance)
    }

}
