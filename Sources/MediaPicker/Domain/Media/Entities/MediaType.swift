/**
 A set of media types that MediaPicker can accept or produce.

 Use `.photo` or `.video` to enable one type, `.photoAndVideo` to enable
 both, or combine individual values with an array literal:

 ```swift
 let mediaTypes: MediaType = [.photo, .video]
 ```
*/
public struct MediaType: OptionSet, Sendable, Hashable {

    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    public static let photo = MediaType(rawValue: MediaPickerConstants.RawValue.photo)
    public static let video = MediaType(rawValue: MediaPickerConstants.RawValue.video)
    public static let photoAndVideo: MediaType = [.photo, .video]

    public func isSupported(
        given availableSources: MediaType
    ) -> Bool {
        isSubset(of: availableSources)
    }

}

extension MediaType: CustomStringConvertible {

    public var description: String {
        switch self {
        case .photo:
            "photo"
        case .video:
            "video"
        case .photoAndVideo:
            "photo and video"
        case []:
            "none"
        default:
            "unknown (raw value: \(rawValue))"
        }
    }

}
