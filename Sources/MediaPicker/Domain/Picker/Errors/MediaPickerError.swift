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

    /// Starting the underlying camera capture session failed.
    case captureSessionStartFailed

    /// Configuring the camera session preset or video input failed.
    case captureSessionConfigurationFailed

    /// Stopping the underlying camera capture session failed.
    case captureSessionStopFailed

    /// Replacing the active camera input failed.
    case captureSessionSwitchFailed

    /// The active camera does not support the requested photo-flash mode.
    case unsupportedFlashMode

    /// The active camera does not support the requested video-torch mode.
    case unsupportedTorchMode

    /// Locking or configuring the active camera device failed.
    case cameraDeviceConfigurationFailed

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
            MediaPickerConstants.Text.sourceUnavailable(Self.description(for: sources)).value
        case let .permissionDenied(permission):
            MediaPickerConstants.Text.permissionDenied(permission.description).value
        case let .invalidConfiguration(reason):
            MediaPickerConstants.Text.invalidConfiguration(reason).value
        case .photoCaptureFailed:
            MediaPickerConstants.Text.photoCaptureFailed.value
        case .videoRecordingFailed:
            MediaPickerConstants.Text.videoRecordingFailed.value
        case .captureSessionStartFailed:
            MediaPickerConstants.Text.captureSessionStartFailed.value
        case .captureSessionConfigurationFailed:
            MediaPickerConstants.Text.captureSessionConfigurationFailed.value
        case .captureSessionStopFailed:
            MediaPickerConstants.Text.captureSessionStopFailed.value
        case .captureSessionSwitchFailed:
            MediaPickerConstants.Text.captureSessionSwitchFailed.value
        case .unsupportedFlashMode:
            MediaPickerConstants.Text.unsupportedFlashMode.value
        case .unsupportedTorchMode:
            MediaPickerConstants.Text.unsupportedTorchMode.value
        case .cameraDeviceConfigurationFailed:
            MediaPickerConstants.Text.cameraDeviceConfigurationFailed.value
        case .photoLibraryLoadingFailed:
            MediaPickerConstants.Text.photoLibraryLoadingFailed.value
        case .unsupportedFormat:
            MediaPickerConstants.Text.unsupportedFormat.value
        case .unknown:
            MediaPickerConstants.Text.unknownFailure.value
        }
    }

    private static func description(for sources: MediaSource) -> String {
        switch sources {
        case .camera:
            MediaPickerConstants.Text.camera.value
        case .photoLibrary:
            MediaPickerConstants.Text.photoLibrary.value
        case .cameraAndPhotoLibrary:
            MediaPickerConstants.Text.cameraAndPhotoLibrary.value
        default:
            MediaPickerConstants.Text.mediaSource.value
        }
    }
}

private extension MediaPickerError.Permission {

    var description: String {
        switch self {
        case .camera:
            MediaPickerConstants.Text.cameraPermission.value
        case .microphone:
            MediaPickerConstants.Text.microphonePermission.value
        case .photoLibrary:
            MediaPickerConstants.Text.photoLibraryPermission.value
        }
    }

}
