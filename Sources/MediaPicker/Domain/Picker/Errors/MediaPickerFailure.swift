//
//  MediaPickerFailure.swift
//  MediaPicker
//
//  Created by Breno Lucas on 02/09/26.
//

/**
 An internal failure that retains its framework cause while exposing only a
 stable `MediaPickerError` to package consumers.
*/
struct MediaPickerFailure: Error {

    let publicError: MediaPickerError
    let underlyingError: any Error

    init(
        _ underlyingError: any Error,
        as publicError: MediaPickerError
    ) {
        self.publicError = publicError
        self.underlyingError = underlyingError
    }

}
