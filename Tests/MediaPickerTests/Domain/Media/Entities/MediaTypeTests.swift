import MediaPicker
import Testing

struct MediaTypeTests {

    @Test func descriptionsExposeReadableMediaTypeNames() {
        #expect(MediaType.photo.description == "photo")
        #expect(MediaType.video.description == "video")
        #expect(MediaType.photoAndVideo.description == "photo and video")
    }

    @Test func photoCanBeRepresentedIndependently() {
        let mediaTypes: MediaType = .photo

        #expect(mediaTypes.contains(.photo))
        #expect(!mediaTypes.contains(.video))
    }

    @Test func videoCanBeRepresentedIndependently() {
        let mediaTypes: MediaType = .video

        #expect(mediaTypes.contains(.video))
        #expect(!mediaTypes.contains(.photo))
    }

    @Test func photoAndVideoCanBeRepresentedByNamedCombination() {
        let mediaTypes: MediaType = .photoAndVideo

        #expect(mediaTypes.contains(.photo))
        #expect(mediaTypes.contains(.video))
    }

    @Test func arrayLiteralProducesThePhotoAndVideoCombination() {
        let mediaTypes: MediaType = [.photo, .video]

        #expect(mediaTypes == .photoAndVideo)
    }

    @Test func individualTypesUseDistinctRawValues() {
        #expect(MediaType.photo.rawValue != MediaType.video.rawValue)
        #expect(MediaType.photo.isDisjoint(with: .video))
    }

    @Test func requestedMediaTypesCanBeCheckedAgainstSupportedTypes() {
        #expect(MediaType.photo.isSupported(given: .photoAndVideo))
        #expect(!MediaType.photoAndVideo.isSupported(given: .photo))
    }

    @Test func mediaTypeIsSendable() {
        requireSendable(MediaType.photoAndVideo)
    }

}

// MARK: Helper Methods
extension MediaTypeTests {

    private func requireSendable<T: Sendable>(_: T) {}

}
