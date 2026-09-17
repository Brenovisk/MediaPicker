//
//  PhotoPreviewLoading.swift
//  MediaPicker
//
//  Created by Breno Lucas on 16/09/26.
//

import Foundation

/** Loads a display-sized representation of a captured photo. */
protocol PhotoPreviewLoading: Sendable {

    func load(from url: URL, maximumPixelSize: Int) async -> PhotoPreviewImage?

}
