//
//  PhotoPreviewImage.swift
//  MediaPicker
//
//  Created by Breno Lucas on 16/09/26.
//

import CoreGraphics

/** Carries a decoded photo preview without exposing its loading technology. */
struct PhotoPreviewImage: @unchecked Sendable {

    let cgImage: CGImage

}
