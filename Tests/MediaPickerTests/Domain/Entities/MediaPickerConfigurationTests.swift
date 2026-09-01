import MediaPicker
import Testing

struct MediaPickerConfigurationTests {

    @Test func defaultConfigurationProducesAValidFlow() {
        let configuration = MediaPickerConfiguration()

        #expect(configuration.sources == .cameraAndPhotoLibrary)
        #expect(configuration.mediaTypes == .photoAndVideo)
        #expect(configuration.initialCameraPosition == .back)
    }

    @Test func sourcesAndMediaTypesAreConfigurable() throws {
        let configuration = try #require(
            MediaPickerConfiguration(
                sources: .photoLibrary,
                mediaTypes: .photo
            )
        )

        #expect(configuration.sources == .photoLibrary)
        #expect(configuration.mediaTypes == .photo)
    }

    @Test func initialCameraPositionIsConfigurable() throws {
        let configuration = try #require(
            MediaPickerConfiguration(
                sources: .camera,
                mediaTypes: .video,
                initialCameraPosition: .front
            )
        )

        #expect(configuration.initialCameraPosition == .front)
    }

    @Test func emptySourcesAreRejected() {
        let configuration = MediaPickerConfiguration(
            sources: [],
            mediaTypes: .photo
        )

        #expect(configuration == nil)
    }

    @Test func emptyMediaTypesAreRejected() {
        let configuration = MediaPickerConfiguration(
            sources: .camera,
            mediaTypes: []
        )

        #expect(configuration == nil)
    }

    @Test func unknownSourceBitsAreRejected() {
        let configuration = MediaPickerConfiguration(
            sources: MediaSource(rawValue: 4),
            mediaTypes: .photo
        )

        #expect(configuration == nil)
    }

    @Test func unknownMediaTypeBitsAreRejected() {
        let configuration = MediaPickerConfiguration(
            sources: .camera,
            mediaTypes: MediaType(rawValue: 4)
        )

        #expect(configuration == nil)
    }

    @Test func configurationIsSendable() {
        requireSendable(MediaPickerConfiguration())
    }

}

// MARK: Helper Methods
extension MediaPickerConfigurationTests {

    private func requireSendable<T: Sendable>(_: T) {}

}
