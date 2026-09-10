import Foundation

/**
 A photo or video obtained from the camera or photo library.

 `CapturedMedia` stores a local file URL instead of loading the media bytes into
 memory. The same model is used for photos and videos, regardless of their
 source.

 The file at `contentURL` is owned by the consumer after the result is
 delivered. URLs inside the system temporary directory are not permanent and
 may be removed by the operating system. Copy or move content that must persist
 to an application-controlled location, and remove temporary content when it is
 no longer needed.
*/
public struct CapturedMedia: Identifiable, Sendable, Equatable {

    public let id: UUID
    public let mediaType: MediaType
    public let source: MediaSource
    public let contentURL: URL

    public init(
        id: UUID = UUID(),
        mediaType: MediaType,
        source: MediaSource,
        contentURL: URL
    ) {
        self.id = id
        self.mediaType = mediaType
        self.source = source
        self.contentURL = contentURL
    }

}
