import MediaPicker
import Testing

struct MediaTypeTests {

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

    @Test func mediaTypeIsSendable() {
        requireSendable(MediaType.photoAndVideo)
    }

    private func requireSendable<T: Sendable>(_: T) {}

}
