//
//  TemporaryMediaFileStoreTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

import Foundation
@testable import MediaPicker
import Testing

struct TemporaryMediaFileStoreTests {

    @Test func savesAndRemovesMediaInsideConfiguredDirectory() throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = TemporaryMediaFileStore(directoryURL: directory)
        let data = Data([1, 2, 3])

        let fileURL = try store.save(
            data,
            fileName: "media",
            fileExtension: "bin"
        )

        #expect(fileURL.deletingLastPathComponent() == directory)
        #expect(try Data(contentsOf: fileURL) == data)

        store.remove(fileURL)

        #expect(FileManager.default.fileExists(atPath: fileURL.path) == false)
    }

    @Test func failedWriteRemovesExistingPartialDestination() throws {
        let directory = temporaryDirectory()
        let destination = directory.appendingPathComponent("media.bin")
        defer { try? FileManager.default.removeItem(at: directory) }
        try FileManager.default.createDirectory(
            at: destination,
            withIntermediateDirectories: true
        )
        let store = TemporaryMediaFileStore(directoryURL: directory)

        #expect(throws: TemporaryMediaFileStoreError.writeFailed) {
            try store.save(
                Data([1]),
                fileName: "media",
                fileExtension: "bin"
            )
        }

        #expect(FileManager.default.fileExists(atPath: destination.path) == false)
    }

    private func temporaryDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
    }

}
