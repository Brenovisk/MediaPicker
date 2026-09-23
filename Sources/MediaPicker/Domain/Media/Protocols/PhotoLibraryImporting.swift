//
//  PhotoLibraryImporting.swift
//  MediaPicker
//
//  Created by Breno Lucas on 18/09/26.
//

import Foundation

/** Imports photo bytes into a temporary file owned by MediaPicker. */
protocol PhotoLibraryImporting: Sendable {

    func importPhoto(_ data: Data) throws -> CapturedMedia

}
