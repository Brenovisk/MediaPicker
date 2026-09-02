import Foundation

/**
 A stable description of a failure produced by MediaPicker.

 Framework-specific errors are mapped to these cases by internal services, so
 consumers do not need to import AVFoundation, PhotosUI, or other implementation
 frameworks. User cancellation is intentionally not represented as an error;
 it is a separate terminal event in the picker flow.
*/
public enum MediaPickerError: Error, Sendable, Equatable, Hashable {

    /** A permission required by a picker operation. */
    public enum Permission: Sendable, Equatable, Hashable {
        case camera
        case microphone
        case photoLibrary
    }

    /// One or more configured sources are unavailable on the current device.
    case sourceUnavailable(MediaSource)

    /// The user denied a permission required by the requested operation.
    case permissionDenied(Permission)

    /// The picker configuration is invalid for the requested flow.
    case invalidConfiguration(String)

    /// Capturing or processing a photo failed.
    case photoCaptureFailed

    /// Starting, completing, or processing a video recording failed.
    case videoRecordingFailed

    /// Loading selected content from the photo library failed.
    case photoLibraryLoadingFailed

    /// The selected or captured content uses an unsupported format.
    case unsupportedFormat

    /// An unexpected failure could not be classified more specifically.
    case unknown
}

extension MediaPickerError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case let .sourceUnavailable(sources):
            "The requested \(Self.description(for: sources)) is unavailable on this device."
        case let .permissionDenied(permission):
            "Permission to access \(permission.description) was denied."
        case let .invalidConfiguration(reason):
            "The MediaPicker configuration is invalid: \(reason)"
        case .photoCaptureFailed:
            "MediaPicker could not capture the photo."
        case .videoRecordingFailed:
            "MediaPicker could not record the video."
        case .photoLibraryLoadingFailed:
            "MediaPicker could not load the selected photo-library item."
        case .unsupportedFormat:
            "The selected media format is not supported."
        case .unknown:
            "MediaPicker encountered an unexpected error."
        }
    }

    private static func description(for sources: MediaSource) -> String {
        switch sources {
        case .camera:
            "camera"
        case .photoLibrary:
            "photo library"
        case .cameraAndPhotoLibrary:
            "camera and photo library"
        default:
            "media source"
        }
    }
}

private extension MediaPickerError.Permission {

    var description: String {
        switch self {
        case .camera:
            "the camera"
        case .microphone:
            "the microphone"
        case .photoLibrary:
            "the photo library"
        }
    }
    
}
