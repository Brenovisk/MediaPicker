/**
 A set of sources from which MediaPicker can obtain media.

 Use `.camera` or `.photoLibrary` to enable one source,
 `.cameraAndPhotoLibrary` to enable both, or combine individual values with an
 array literal:

 ```swift
 let sources: MediaSource = [.camera, .photoLibrary]
 ```
*/
public struct MediaSource: OptionSet, Sendable, Hashable {

    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    public static let camera = MediaSource(rawValue: 1)
    public static let photoLibrary = MediaSource(rawValue: 2)
    public static let cameraAndPhotoLibrary: MediaSource = [.camera, .photoLibrary]

    /**
     The enabled individual sources in their presentation order.

     Camera is presented before the photo library when both are enabled.
    */
    public var orderedSources: [MediaSource] {
        Self.presentationOrder.filter(contains)
    }

    /**
     Returns the requested sources that are absent from `availableSources`.

     Use this before presentation to decide whether the configured flow can be
     offered on the current device.
    */
    public func unsupportedSources(
        given availableSources: MediaSource
    ) -> MediaSource {
        subtracting(availableSources)
    }

    /**
     Indicates whether every requested source is present in `availableSources`.
    */
    public func isSupported(
        given availableSources: MediaSource
    ) -> Bool {
        isSubset(of: availableSources)
    }

    private static let presentationOrder: [MediaSource] = [.camera, .photoLibrary]

}
