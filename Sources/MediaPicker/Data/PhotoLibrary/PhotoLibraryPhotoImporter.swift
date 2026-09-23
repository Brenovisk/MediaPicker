//
//  PhotoLibraryPhotoImporter.swift
//  MediaPicker
//
//  Created by Breno Lucas on 18/09/26.
//

import Foundation
import ImageIO
import UniformTypeIdentifiers

/** Validates a selected image and preserves its original bytes in temporary storage. */
struct PhotoLibraryPhotoImporter: PhotoLibraryImporting {

    private let fileStore: TemporaryMediaFileStore

    init(fileStore: TemporaryMediaFileStore = TemporaryMediaFileStore()) {
        self.fileStore = fileStore
    }

    func importPhoto(_ data: Data) throws -> CapturedMedia {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              CGImageSourceGetCount(source) > 0,
              let identifier = CGImageSourceGetType(source) as String?,
              let type = UTType(identifier),
              let fileExtension = type.preferredFilenameExtension
        else {
            throw MediaPickerError.photoLibraryLoadingFailed
        }

        let id = UUID()
        let url: URL

        do {
            url = try fileStore.save(
                data,
                fileName: id.uuidString,
                fileExtension: fileExtension
            )
        } catch {
            throw MediaPickerError.photoLibraryLoadingFailed
        }

        return CapturedMedia(
            id: id,
            mediaType: .photo,
            source: .photoLibrary,
            contentURL: url
        )
    }

}
