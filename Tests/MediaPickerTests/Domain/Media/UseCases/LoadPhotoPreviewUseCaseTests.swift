//
//  LoadPhotoPreviewUseCaseTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 16/09/26.
//

import Foundation
@testable import MediaPicker
import Testing

struct LoadPhotoPreviewUseCaseTests {

    @Test func forwardsFileAndRequestedSizeToLoader() async {
        let loader = PhotoPreviewLoaderSpy()
        let useCase = LoadPhotoPreviewUseCase(loader: loader)
        let url = URL(fileURLWithPath: "/tmp/photo.jpg")

        _ = await useCase.execute(from: url, maximumPixelSize: 2_048)

        #expect(await loader.receivedURL == url)
        #expect(await loader.receivedMaximumPixelSize == 2_048)
    }

}
