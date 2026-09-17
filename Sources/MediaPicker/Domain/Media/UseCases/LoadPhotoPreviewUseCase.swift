//
//  LoadPhotoPreviewUseCase.swift
//  MediaPicker
//
//  Created by Breno Lucas on 16/09/26.
//

import Foundation

/** Loads a lightweight image representation for captured-photo review. */
struct LoadPhotoPreviewUseCase: Sendable {

    private let loader: any PhotoPreviewLoading

    init(loader: any PhotoPreviewLoading) {
        self.loader = loader
    }

    func execute(from url: URL, maximumPixelSize: Int) async -> PhotoPreviewImage? {
        await loader.load(from: url, maximumPixelSize: maximumPixelSize)
    }

}
