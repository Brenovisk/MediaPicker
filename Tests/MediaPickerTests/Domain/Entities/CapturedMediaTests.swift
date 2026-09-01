import Foundation
import MediaPicker
import Testing

struct CapturedMediaTests {

    @Test func photoAndVideoUseTheSameResultModel() {
        let photo = makeCapturedMedia(mediaType: .photo)
        let video = makeCapturedMedia(mediaType: .video)

        #expect(photo.mediaType == .photo)
        #expect(video.mediaType == .video)
    }

    @Test func resultIdentifiesItsSource() {
        let cameraResult = makeCapturedMedia(source: .camera)
        let libraryResult = makeCapturedMedia(source: .photoLibrary)

        #expect(cameraResult.source == .camera)
        #expect(libraryResult.source == .photoLibrary)
    }

    @Test func resultExposesContentThroughAFileURL() {
        let contentURL = URL(fileURLWithPath: "/tmp/captured-photo.jpg")
        let media = makeCapturedMedia(contentURL: contentURL)

        #expect(media.contentURL == contentURL)
        #expect(media.contentURL.isFileURL)
    }

    @Test func defaultIdentityIsUniqueForEachResult() {
        let firstResult = makeCapturedMedia()
        let secondResult = makeCapturedMedia()

        #expect(firstResult.id != secondResult.id)
        #expect(firstResult != secondResult)
    }

    @Test func resultsWithTheSameValuesAreEqual() {
        let id = UUID()
        let contentURL = URL(fileURLWithPath: "/tmp/captured-photo.jpg")
        let firstResult = makeCapturedMedia(id: id, contentURL: contentURL)
        let secondResult = makeCapturedMedia(id: id, contentURL: contentURL)

        #expect(firstResult == secondResult)
    }

    @Test func capturedMediaIsSendable() {
        requireSendable(makeCapturedMedia())
    }

}

// MARK: Helper Methods
extension CapturedMediaTests {

    private func makeCapturedMedia(
        id: UUID = UUID(),
        mediaType: MediaType = .photo,
        source: MediaSource = .camera,
        contentURL: URL = URL(fileURLWithPath: "/tmp/captured-media")
    ) -> CapturedMedia {
        CapturedMedia(
            id: id,
            mediaType: mediaType,
            source: source,
            contentURL: contentURL
        )
    }

    private func requireSendable<T: Sendable>(_: T) {}

}
