//
//  CameraPreviewFraming.swift
//  MediaPicker
//
//  Created by Breno Lucas on 22/09/26.
//

/** Describes the exact visible camera viewport without exposing UI frameworks. */
struct CameraPreviewFraming: Sendable, Equatable {

    let aspectRatio: Double
    let normalizedCrop: CameraNormalizedRect?

    init?(aspectRatio: Double, normalizedCrop: CameraNormalizedRect? = nil) {
        guard aspectRatio.isFinite, aspectRatio > .zero else { return nil }
        self.aspectRatio = aspectRatio
        self.normalizedCrop = normalizedCrop
    }

}

/** A validated crop rectangle expressed in normalized image coordinates. */
struct CameraNormalizedRect: Sendable, Equatable {

    let originX: Double
    let originY: Double
    let width: Double
    let height: Double

    init?(originX: Double, originY: Double, width: Double, height: Double) {
        let values = [originX, originY, width, height]
        guard values.allSatisfy(\.isFinite),
              originX >= .zero,
              originY >= .zero,
              width > .zero,
              height > .zero,
              originX + width <= 1,
              originY + height <= 1 else { return nil }

        self.originX = originX
        self.originY = originY
        self.width = width
        self.height = height
    }

}
