//
//  PhotoPreviewLoaderSpy.swift
//  MediaPicker
//
//  Created by Breno Lucas on 16/09/26.
//

import Foundation
@testable import MediaPicker

actor PhotoPreviewLoaderSpy: PhotoPreviewLoading {

    private(set) var receivedURL: URL?
    private(set) var receivedMaximumPixelSize: Int?

    func load(from url: URL, maximumPixelSize: Int) -> PhotoPreviewImage? {
        receivedURL = url
        receivedMaximumPixelSize = maximumPixelSize
        return nil
    }

}
