//
//  ImportPhotoFromLibraryUseCase.swift
//  MediaPicker
//
//  Created by Breno Lucas on 18/09/26.
//

import Foundation

/** Converts a selected library item's bytes into a MediaPicker result. */
struct ImportPhotoFromLibraryUseCase {

    private let importer: any PhotoLibraryImporting

    init(importer: any PhotoLibraryImporting) {
        self.importer = importer
    }

    func execute(_ data: Data) throws -> CapturedMedia {
        try importer.importPhoto(data)
    }

}
