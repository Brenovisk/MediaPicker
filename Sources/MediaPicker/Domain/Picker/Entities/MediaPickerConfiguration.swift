import Foundation

/**
 The sources, media types, and initial camera used by a picker flow.

 The default configuration enables the camera and photo library, accepts photos
 and videos, and starts with the back camera:

 ```swift
 let configuration = MediaPickerConfiguration()
 ```

 Use the throwing initializer for custom values. It reports invalid static
 values before capture or photo-library infrastructure is started. Dynamic
 device availability is evaluated separately immediately before presentation.
*/
public struct MediaPickerConfiguration: Sendable, Equatable {

    public let sources: MediaSource
    public let mediaTypes: MediaType
    public let initialCameraPosition: CameraPosition
    public let maximumVideoDuration: TimeInterval?

    public init() {
        sources = .cameraAndPhotoLibrary
        mediaTypes = .photoAndVideo
        initialCameraPosition = .back
        maximumVideoDuration = nil
    }

    /**
     Creates a custom configuration when every static value is valid.

     - Throws: `MediaPickerError.invalidConfiguration` with a reason identifying
       an empty or unknown option set, or an invalid video-duration limit.

     - Parameters:
       - sources: One or more enabled media sources.
       - mediaTypes: One or more accepted media types.
       - initialCameraPosition: The preferred initial camera. Defaults to back.
       - maximumVideoDuration: An optional positive, finite duration in seconds.
         `nil` means that MediaPicker does not impose a duration limit.
    */
    public init(
        sources: MediaSource,
        mediaTypes: MediaType,
        initialCameraPosition: CameraPosition = .back,
        maximumVideoDuration: TimeInterval? = nil
    ) throws {
        try Self.validateStaticValues(
            sources: sources,
            mediaTypes: mediaTypes,
            maximumVideoDuration: maximumVideoDuration
        )

        self.sources = sources
        self.mediaTypes = mediaTypes
        self.initialCameraPosition = initialCameraPosition
        self.maximumVideoDuration = maximumVideoDuration
    }

    /// Checks device support separately from static configuration validation.
    public func validateAvailability(
        availableSources: MediaSource,
        supportedMediaTypes: MediaType
    ) throws {
        let unavailableSources = sources.unsupportedSources(given: availableSources)

        guard unavailableSources.isEmpty else {
            throw MediaPickerError.sourceUnavailable(unavailableSources)
        }

        guard mediaTypes.isSupported(given: supportedMediaTypes) else {
            throw MediaPickerError.unsupportedFormat
        }
    }

}

// MARK: Helper Methods
extension MediaPickerConfiguration {

    private static func validateStaticValues(
        sources: MediaSource,
        mediaTypes: MediaType,
        maximumVideoDuration: TimeInterval?
    ) throws {
        try validate([
            (!sources.isEmpty, .emptySources),
            (sources.isSupported(given: .cameraAndPhotoLibrary), .unknownSource),
            (!mediaTypes.isEmpty, .emptyMediaTypes),
            (mediaTypes.isSupported(given: .photoAndVideo), .unknownMediaType)
        ])

        if let maximumVideoDuration {
            try validate([
                (mediaTypes.contains(.video), .durationRequiresVideo),
                (maximumVideoDuration.isFinite && maximumVideoDuration >
                MediaPickerConstants.Number.minimumVideoDuration,
                    .invalidVideoDuration
                )
            ])
        }
    }

    private static func validate(_ rules: [ValidationRule]) throws {
        if let failedRule = rules.first(where: { !$0.isValid }) {
            throw MediaPickerError.invalidConfiguration(failedRule.error.value)
        }
    }

    private typealias ValidationRule = (
        isValid: Bool,
        error: MediaPickerConstants.Text
    )

}
