//
//  PhotoDataEncoder.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

import Foundation
import ImageIO
import UniformTypeIdentifiers

/** Validates camera image data and converts it to the selected output format. */
struct PhotoDataEncoder: Sendable {

    func encode(
        _ data: Data,
        as format: PhotoOutputFormat,
        previewFraming: CameraPreviewFraming? = nil
    ) throws -> EncodedPhoto {
        guard data.isEmpty == false,
              let source = CGImageSourceCreateWithData(data as CFData, nil),
              CGImageSourceGetStatus(source) == .statusComplete,
              let typeIdentifier = CGImageSourceGetType(source) else {
            throw MediaPickerError.photoCaptureFailed
        }

        let croppedImage: CGImage?
        if let previewFraming {
            croppedImage = try PhotoAspectRatioCropper().cropIfNeeded(
                source,
                using: previewFraming
            )
        } else {
            croppedImage = nil
        }

        if croppedImage == nil,
           UTType(typeIdentifier as String)?.conforms(to: format.contentType) == true {
            return EncodedPhoto(data: data, fileExtension: format.fileExtension)
        }

        let image = try croppedImage
            ?? PhotoAspectRatioCropper().orientedImage(source)

        let outputData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            outputData,
            format.contentType.identifier as CFString,
            1,
            nil
        ) else {
            throw MediaPickerError.photoCaptureFailed
        }

        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else {
            throw MediaPickerError.photoCaptureFailed
        }

        return EncodedPhoto(
            data: outputData as Data,
            fileExtension: format.fileExtension
        )
    }

}

struct EncodedPhoto: Sendable {

    let data: Data
    let fileExtension: String

}

private extension PhotoOutputFormat {

    var fileExtension: String {
        switch self {
        case .jpeg:
            "jpg"
        case .png:
            "png"
        }
    }

    var contentType: UTType {
        switch self {
        case .jpeg:
            .jpeg
        case .png:
            .png
        }
    }

}
