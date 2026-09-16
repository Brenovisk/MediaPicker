//
//  DiscardCapturedMediaUseCaseTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 16/09/26.
//

import Foundation
@testable import MediaPicker
import Testing

struct DiscardCapturedMediaUseCaseTests {

    @Test func forwardsDiscardedMediaToStorage() {
        let media = CapturedMedia(
            mediaType: .photo,
            source: .camera,
            contentURL: URL(fileURLWithPath: "/tmp/photo.jpeg")
        )
        let discarder = CapturedMediaDiscarderSpy()
        let useCase = DiscardCapturedMediaUseCase(mediaDiscarder: discarder)

        useCase.execute(media: media)

        #expect(discarder.discardedMedia == [media])
    }

}
