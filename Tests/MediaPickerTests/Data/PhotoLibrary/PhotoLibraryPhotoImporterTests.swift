//
//  PhotoLibraryPhotoImporterTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 18/09/26.
//

import Foundation
@testable import MediaPicker
import Testing

struct PhotoLibraryPhotoImporterTests {

    @Test func selectedPhotoIsSavedAndIdentifiedAsLibraryMedia() throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let data = try CapturedPhotoFixture.jpegData()
        let importer = PhotoLibraryPhotoImporter(
            fileStore: TemporaryMediaFileStore(directoryURL: directory)
        )

        let media = try ImportPhotoFromLibraryUseCase(importer: importer).execute(data)

        #expect(media.mediaType == .photo)
        #expect(media.source == .photoLibrary)
        #expect(media.contentURL.pathExtension == "jpeg" || media.contentURL.pathExtension == "jpg")
        #expect(try Data(contentsOf: media.contentURL) == data)
    }

    @Test func invalidSelectedDataDoesNotCreateAMediaFile() throws {
        let directory = temporaryDirectory()
        let importer = PhotoLibraryPhotoImporter(
            fileStore: TemporaryMediaFileStore(directoryURL: directory)
        )

        #expect(throws: MediaPickerError.photoLibraryLoadingFailed) {
            try importer.importPhoto(Data())
        }
        #expect(FileManager.default.fileExists(atPath: directory.path) == false)
    }

    private func temporaryDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
    }

}
