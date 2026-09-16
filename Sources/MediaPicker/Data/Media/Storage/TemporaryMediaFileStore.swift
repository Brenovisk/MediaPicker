//
//  TemporaryMediaFileStore.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

import Foundation

/** Persists camera media atomically inside MediaPicker's temporary directory. */
struct TemporaryMediaFileStore: Sendable {

    private let directoryURL: URL

    init(directoryURL: URL = Self.defaultDirectoryURL) {
        self.directoryURL = directoryURL
    }

    func save(
        _ data: Data,
        fileName: String,
        fileExtension: String
    ) throws -> URL {
        let fileURL = directoryURL
            .appendingPathComponent(fileName)
            .appendingPathExtension(fileExtension)

        do {
            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )
            try data.write(to: fileURL, options: .atomic)
            return fileURL
        } catch {
            remove(fileURL)
            throw TemporaryMediaFileStoreError.writeFailed
        }
    }

    func remove(_ fileURL: URL) {
        try? FileManager.default.removeItem(at: fileURL)
    }

    private static var defaultDirectoryURL: URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(
                MediaPickerInfrastructureConstants.temporaryMediaDirectoryName,
                isDirectory: true
            )
    }

}

extension TemporaryMediaFileStore: CapturedMediaDiscarding {

    func discard(_ media: CapturedMedia) {
        remove(media.contentURL)
    }

}

enum TemporaryMediaFileStoreError: Error {
    case writeFailed
}
