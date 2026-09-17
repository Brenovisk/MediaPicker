//
//  CapturedMediaDiscarding.swift
//  MediaPicker
//
//  Created by Breno Lucas on 16/09/26.
//

/** Removes media that the picker captured but did not deliver to its consumer. */
protocol CapturedMediaDiscarding: Sendable {

    func discard(_ media: CapturedMedia)

}
