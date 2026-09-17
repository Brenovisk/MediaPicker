//
//  ImageIOPhotoPreviewLoaderTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 16/09/26.
//

import Foundation
@testable import MediaPicker
import Testing

struct ImageIOPhotoPreviewLoaderTests {

    @Test func loadsAValidCapturedPhoto() async throws {
        let url = temporaryFileURL()
        defer { try? FileManager.default.removeItem(at: url) }
        try CapturedPhotoFixture.jpegData().write(to: url)

        let preview = await ImageIOPhotoPreviewLoader().load(
            from: url,
            maximumPixelSize: 2_048
        )

        #expect(preview?.cgImage.width == 1)
        #expect(preview?.cgImage.height == 1)
    }

    @Test func missingFileProducesNoPreview() async {
        let preview = await ImageIOPhotoPreviewLoader().load(
            from: temporaryFileURL(),
            maximumPixelSize: 2_048
        )

        #expect(preview == nil)
    }

    private func temporaryFileURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("jpg")
    }

}
