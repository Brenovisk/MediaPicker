import Foundation
import MediaPicker
import Testing

struct MediaPickerConfigurationValidationTests {

    @Test func emptySourcesAreRejectedWithASpecificMessage() {
        #expect(throws: MediaPickerError.invalidConfiguration(
            "At least one media source must be enabled."
        )) {
            try MediaPickerConfiguration(
                sources: [],
                mediaTypes: .photo
            )
        }
    }

    @Test func emptyMediaTypesAreRejectedWithASpecificMessage() {
        #expect(throws: MediaPickerError.invalidConfiguration(
            "At least one media type must be enabled."
        )) {
            try MediaPickerConfiguration(
                sources: .camera,
                mediaTypes: []
            )
        }
    }

    @Test func unknownSourcesAreRejected() {
        #expect(throws: MediaPickerError.invalidConfiguration(
            "The configuration contains an unknown media source."
        )) {
            try MediaPickerConfiguration(
                sources: MediaSource(rawValue: 4),
                mediaTypes: .photo
            )
        }
    }

    @Test func unknownMediaTypesAreRejected() {
        #expect(throws: MediaPickerError.invalidConfiguration(
            "The configuration contains an unknown media type."
        )) {
            try MediaPickerConfiguration(
                sources: .camera,
                mediaTypes: MediaType(rawValue: 4)
            )
        }
    }

    @Test(arguments: [
        TimeInterval(0),
        TimeInterval(-1),
        TimeInterval.infinity,
        -TimeInterval.infinity,
        TimeInterval.nan
    ])
    func invalidMaximumVideoDurationsAreRejected(duration: TimeInterval) {
        #expect(throws: MediaPickerError.invalidConfiguration(
            "The maximum video duration must be a positive, finite number of seconds."
        )) {
            try MediaPickerConfiguration(
                sources: .camera,
                mediaTypes: .video,
                maximumVideoDuration: duration
            )
        }
    }

    @Test func videoDurationRequiresVideoToBeEnabled() {
        #expect(throws: MediaPickerError.invalidConfiguration(
            "A maximum video duration requires video to be enabled."
        )) {
            try MediaPickerConfiguration(
                sources: .camera,
                mediaTypes: .photo,
                maximumVideoDuration: 30
            )
        }
    }

    @Test func unavailableCameraIsADynamicAvailabilityError() throws {
        let configuration = try MediaPickerConfiguration(
            sources: .camera,
            mediaTypes: .photo
        )

        #expect(throws: MediaPickerError.sourceUnavailable(.camera)) {
            try configuration.validateAvailability(
                availableSources: .photoLibrary,
                supportedMediaTypes: .photoAndVideo
            )
        }
    }

    @Test func unavailablePhotoLibraryIsADynamicAvailabilityError() throws {
        let configuration = try MediaPickerConfiguration(
            sources: .photoLibrary,
            mediaTypes: .photo
        )

        #expect(throws: MediaPickerError.sourceUnavailable(.photoLibrary)) {
            try configuration.validateAvailability(
                availableSources: .camera,
                supportedMediaTypes: .photoAndVideo
            )
        }
    }

    @Test func unsupportedVideoIsADynamicCapabilityError() throws {
        let configuration = try MediaPickerConfiguration(
            sources: .camera,
            mediaTypes: .video
        )

        #expect(throws: MediaPickerError.unsupportedFormat) {
            try configuration.validateAvailability(
                availableSources: .camera,
                supportedMediaTypes: .photo
            )
        }
    }

    @Test func supportedConfigurationPassesAvailabilityValidation() throws {
        let configuration = try MediaPickerConfiguration(
            sources: .cameraAndPhotoLibrary,
            mediaTypes: .photoAndVideo,
            maximumVideoDuration: 30
        )

        try configuration.validateAvailability(
            availableSources: .cameraAndPhotoLibrary,
            supportedMediaTypes: .photoAndVideo
        )
    }

}
