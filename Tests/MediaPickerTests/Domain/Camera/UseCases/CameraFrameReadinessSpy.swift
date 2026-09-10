//
//  CameraFrameReadinessSpy.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

#if os(iOS)
@testable import MediaPicker
import Testing

@MainActor
final class CameraFrameReadinessSpy: CameraFrameReadinessProviding {

    let latestFrameSequence: UInt64?
    private var readinessResults: [Bool]
    private(set) var requestedSequences: [UInt64?] = []

    init(latestFrameSequence: UInt64?, readinessResults: [Bool]) {
        self.latestFrameSequence = latestFrameSequence
        self.readinessResults = readinessResults
    }

    func waitForFrame(after sequence: UInt64?) async -> Bool {
        requestedSequences.append(sequence)
        return readinessResults.removeFirst()
    }

}

#endif
