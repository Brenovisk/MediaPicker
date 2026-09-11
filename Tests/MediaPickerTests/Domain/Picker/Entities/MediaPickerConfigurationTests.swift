import MediaPicker
import Testing

struct MediaPickerConfigurationTests {

    @Test func defaultConfigurationProducesAValidFlow() {
        let configuration = MediaPickerConfiguration()

        #expect(configuration.sources == .cameraAndPhotoLibrary)
        #expect(configuration.mediaTypes == .photoAndVideo)
        #expect(configuration.initialCameraPosition == .back)
        #expect(configuration.photoOutputFormat == .jpeg)
        #expect(configuration.maximumVideoDuration == nil)
    }

    @Test func sourcesAndMediaTypesAreConfigurable() throws {
        let configuration = try MediaPickerConfiguration(
            sources: .photoLibrary,
            mediaTypes: .photo
        )

        #expect(configuration.sources == .photoLibrary)
        #expect(configuration.mediaTypes == .photo)
    }

    @Test func initialCameraPositionIsConfigurable() throws {
        let configuration = try MediaPickerConfiguration(
            sources: .camera,
            mediaTypes: .video,
            initialCameraPosition: .front
        )

        #expect(configuration.initialCameraPosition == .front)
    }

    @Test func maximumVideoDurationIsConfigurable() throws {
        let configuration = try MediaPickerConfiguration(
            sources: .camera,
            mediaTypes: .video,
            maximumVideoDuration: 30
        )

        #expect(configuration.maximumVideoDuration == 30)
    }

    @Test func photoOutputFormatIsConfigurable() throws {
        let configuration = try MediaPickerConfiguration(
            sources: .camera,
            mediaTypes: .photo,
            photoOutputFormat: .png
        )

        #expect(configuration.photoOutputFormat == .png)
    }

    @Test func configurationsWithTheSameValuesAreEqual() throws {
        let firstConfiguration = try makeConfiguration()
        let secondConfiguration = try makeConfiguration()

        #expect(firstConfiguration == secondConfiguration)
    }

    @Test func configurationsWithDifferentValuesAreNotEqual() throws {
        let firstConfiguration = try makeConfiguration()
        let secondConfiguration = try MediaPickerConfiguration(
            sources: .camera,
            mediaTypes: .video,
            initialCameraPosition: .front,
            maximumVideoDuration: 60
        )

        #expect(firstConfiguration != secondConfiguration)
    }

    @Test func configurationIsSendable() {
        requireSendable(MediaPickerConfiguration())
    }

}

// MARK: Helper Methods
extension MediaPickerConfigurationTests {

    private func makeConfiguration() throws -> MediaPickerConfiguration {
        try MediaPickerConfiguration(
            sources: .camera,
            mediaTypes: .video,
            initialCameraPosition: .front,
            maximumVideoDuration: 30
        )
    }

    private func requireSendable<T: Sendable>(_: T) {}

}
