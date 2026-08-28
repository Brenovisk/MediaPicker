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

    public static let photo = MediaType(rawValue: 1)
    public static let video = MediaType(rawValue: 2)
    public static let photoAndVideo: MediaType = [.photo, .video]

}
