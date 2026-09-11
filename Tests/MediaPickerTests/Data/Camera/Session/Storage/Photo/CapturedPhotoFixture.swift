//
//  CapturedPhotoFixture.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

/** Creates valid in-memory photo data without requiring camera hardware. */
enum CapturedPhotoFixture {

    static func jpegData() throws -> Data {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ), let image = context.makeImage() else {
            throw FixtureError.creationFailed
        }

        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            data,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            throw FixtureError.creationFailed
        }

        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else {
            throw FixtureError.creationFailed
        }

        return data as Data
    }

    enum FixtureError: Error {
        case creationFailed
    }

}
