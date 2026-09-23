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

    static func jpegData(
        width: Int = 1,
        height: Int = 1,
        orientation: Int = 1
    ) throws -> Data {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
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

        CGImageDestinationAddImage(
            destination,
            image,
            [kCGImagePropertyOrientation: orientation] as CFDictionary
        )
        guard CGImageDestinationFinalize(destination) else {
            throw FixtureError.creationFailed
        }

        return data as Data
    }

    enum FixtureError: Error {
        case creationFailed
    }

}
