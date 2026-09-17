//
//  DiscardCapturedMediaUseCase.swift
//  MediaPicker
//
//  Created by Breno Lucas on 16/09/26.
//

/** Discards a temporary result when the user cancels or requests a retake. */
struct DiscardCapturedMediaUseCase: Sendable {

    private let mediaDiscarder: any CapturedMediaDiscarding

    init(mediaDiscarder: any CapturedMediaDiscarding) {
        self.mediaDiscarder = mediaDiscarder
    }

    func execute(media: CapturedMedia) {
        mediaDiscarder.discard(media)
    }

}
