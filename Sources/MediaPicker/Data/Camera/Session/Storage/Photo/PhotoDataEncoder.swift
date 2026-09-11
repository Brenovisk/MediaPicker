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

    func encode(_ data: Data, as format: PhotoOutputFormat) throws -> EncodedPhoto {
        guard data.isEmpty == false,
              let source = CGImageSourceCreateWithData(data as CFData, nil),
              CGImageSourceGetStatus(source) == .statusComplete,
              let typeIdentifier = CGImageSourceGetType(source) else {
            throw MediaPickerError.photoCaptureFailed
        }

        if UTType(typeIdentifier as String)?.conforms(to: format.contentType) == true {
            return EncodedPhoto(data: data, fileExtension: format.fileExtension)
        }

        guard let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw MediaPickerError.photoCaptureFailed
        }

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
