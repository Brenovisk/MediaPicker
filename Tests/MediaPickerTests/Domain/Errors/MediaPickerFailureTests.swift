//
//  MediaPickerFailure.swift
//  MediaPicker
//
//  Created by Breno Lucas on 02/09/26.
//

import Foundation
@testable import MediaPicker
import Testing

struct MediaPickerFailureTests {

    @Test func internalMappingPreservesFrameworkCause() {
        let cause = StubFrameworkError()
        let failure = MediaPickerFailure(cause, as: .photoCaptureFailed)
        #expect(failure.publicError == .photoCaptureFailed)
        #expect(failure.underlyingError is StubFrameworkError)
    }

}

// MARK: Helper Methods
extension MediaPickerFailureTests {

    private struct StubFrameworkError: Error {}
    private func requireSendable<T: Sendable>(_: T) {}

}
