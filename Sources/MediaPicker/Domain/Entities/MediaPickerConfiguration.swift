/**
 The sources, media types, and initial camera used by a picker flow.

 The default configuration enables the camera and photo library, accepts photos
 and videos, and starts with the back camera:

 ```swift
 let configuration = MediaPickerConfiguration()
 ```

 Use the failable initializer for custom values. It rejects empty sets and raw
 option bits that MediaPicker does not recognize, preventing an invalid static
 configuration from reaching capture or photo-library infrastructure.
*/
public struct MediaPickerConfiguration: Sendable, Equatable {

    public let sources: MediaSource
    public let mediaTypes: MediaType
    public let initialCameraPosition: CameraPosition

    public init() {
        sources = .cameraAndPhotoLibrary
        mediaTypes = .photoAndVideo
        initialCameraPosition = .back
    }

    /**
     Creates a custom configuration when every static value is recognized.

     Returns `nil` when `sources` or `mediaTypes` is empty or contains unknown
     raw option bits. Device-dependent availability is evaluated separately
     immediately before presentation.

     - Parameters:
       - sources: One or more enabled media sources.
       - mediaTypes: One or more accepted media types.
       - initialCameraPosition: The preferred initial camera. Defaults to back.
    */
    public init?(
        sources: MediaSource,
        mediaTypes: MediaType,
        initialCameraPosition: CameraPosition = .back
    ) {
        guard Self.isRecognized(sources), Self.isRecognized(mediaTypes) else {
            return nil
        }

        self.sources = sources
        self.mediaTypes = mediaTypes
        self.initialCameraPosition = initialCameraPosition
    }

}

// MARK: Helper Methods
extension MediaPickerConfiguration {

    private static func isRecognized(_ sources: MediaSource) -> Bool {
        !sources.isEmpty && sources.isSupported(given: .cameraAndPhotoLibrary)
    }

    private static func isRecognized(_ mediaTypes: MediaType) -> Bool {
        !mediaTypes.isEmpty && mediaTypes.isSupported(given: .photoAndVideo)
    }

}
