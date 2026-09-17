//
//  PhotoCaptureDelegateStore.swift
//  MediaPicker
//
//  Created by Breno Lucas on 15/09/26.
//

import Foundation

/** Retains photo delegates until AVFoundation completes or cancels each request. */
final class PhotoCaptureDelegateStore: @unchecked Sendable {

    private let lock = NSLock()
    private var delegates: [Int64: PhotoCaptureCompletionDelegate] = [:]

    var isEmpty: Bool {
        lock.withLock { delegates.isEmpty }
    }

    func insert(_ delegate: PhotoCaptureCompletionDelegate, for requestID: Int64) {
        lock.withLock {
            delegates[requestID] = delegate
        }
    }

    func remove(for requestID: Int64) {
        lock.withLock {
            delegates[requestID] = nil
        }
    }

    func cancelAll() {
        let activeDelegates = lock.withLock {
            let activeDelegates = Array(delegates.values)
            delegates.removeAll()
            return activeDelegates
        }
        activeDelegates.forEach { $0.cancel() }
    }

}
