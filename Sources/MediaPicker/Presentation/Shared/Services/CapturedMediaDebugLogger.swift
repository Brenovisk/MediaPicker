//
//  CapturedMediaDebugLogger.swift
//  MediaPicker
//
//  Created by Breno Lucas on 16/09/26.
//

import Foundation

/** Prints confirmed media details during development without affecting release builds. */
enum CapturedMediaDebugLogger {

    static func logConfirmation(of media: CapturedMedia) {
        #if DEBUG
        let fileSize = try? media.contentURL.resourceValues(
            forKeys: [.fileSizeKey]
        ).fileSize
        let fileSizeInMegabytes = Double(fileSize ?? 0) / bytesPerMegabyte

        debugPrint("Captured photo confirmed")
        debugPrint("ID: \(media.id)")
        debugPrint("Media type: \(media.mediaType)")
        debugPrint("Source: \(media.source)")
        debugPrint("File URL: \(media.contentURL.path)")
        debugPrint("File size: \(String(format: "%.2f", fileSizeInMegabytes)) MB")
        #endif
    }

    private static let bytesPerMegabyte = 1_000_000.0

}
