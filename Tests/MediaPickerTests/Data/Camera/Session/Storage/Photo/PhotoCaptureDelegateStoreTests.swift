//
//  PhotoCaptureDelegateStoreTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 15/09/26.
//

@testable import MediaPicker
import Testing

struct PhotoCaptureDelegateStoreTests {

    @Test func cancellationResumesAndReleasesEveryPendingCapture() async {
        let store = PhotoCaptureDelegateStore()
        var receivedFailure = false

        do {
            let _: CapturedMedia = try await withCheckedThrowingContinuation { continuation in
                let delegate = PhotoCaptureCompletionDelegate(
                    processor: PhotoCaptureResultProcessor(
                        request: CameraPhotoCaptureRequest(id: 1),
                        format: .jpeg
                    ),
                    continuation: continuation,
                    onCompletion: { store.remove(for: 1) }
                )
                store.insert(delegate, for: 1)
                #expect(store.isEmpty == false)

                store.cancelAll()
            }
        } catch {
            receivedFailure = true
        }

        #expect(receivedFailure)
        #expect(store.isEmpty)
    }

}
