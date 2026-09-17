//
//  CapturedMediaDiscarderSpy.swift
//  MediaPicker
//
//  Created by Breno Lucas on 16/09/26.
//

import Foundation
@testable import MediaPicker

final class CapturedMediaDiscarderSpy: @unchecked Sendable,
    CapturedMediaDiscarding {

    private let lock = NSLock()
    private var storedMedia: [CapturedMedia] = []

    var discardedMedia: [CapturedMedia] {
        lock.withLock { storedMedia }
    }

    func discard(_ media: CapturedMedia) {
        lock.withLock {
            storedMedia.append(media)
        }
    }

}
