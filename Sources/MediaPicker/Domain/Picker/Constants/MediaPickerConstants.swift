import Foundation

enum MediaPickerConstants {

    enum Text {
        case greeting
        case switchCamera

        case photoCaptureFailed
        case videoRecordingFailed
        case captureSessionConfigurationFailed
        case captureSessionStartFailed
        case captureSessionStopFailed
        case captureSessionSwitchFailed
        case unsupportedFlashMode
        case unsupportedTorchMode
        case cameraDeviceConfigurationFailed
        case cameraInUse
        case cameraUnavailable
        case captureSessionRuntimeFailed
        case mediaServicesResetRecoveryFailed
        case photoLibraryLoadingFailed
        case unsupportedFormat
        case unknownFailure

        case camera
        case photoLibrary
        case cameraAndPhotoLibrary
        case mediaSource

        case cameraPermission
        case microphonePermission
        case photoLibraryPermission

        case emptySources
        case unknownSource
        case emptyMediaTypes
        case unknownMediaType
        case durationRequiresVideo
        case invalidVideoDuration
        case sourceUnavailable(_ source: String)
        case permissionDenied(_ permission: String)
        case invalidConfiguration(_ reason: String)
    }

    enum RawValue {
        static let photo: UInt8 = 1
        static let video: UInt8 = 2
        static let camera: UInt8 = 1
        static let photoLibrary: UInt8 = 2
    }

    enum Number {
        static let minimumVideoDuration: TimeInterval = .zero
    }

}

extension MediaPickerConstants.Text {

    var value: String {
        switch self {
        case .greeting:
            return "Olá do meu SPM Framework!"
        case .switchCamera:
            return "Switch camera"

        case .photoCaptureFailed:
            return "MediaPicker could not capture the photo."
        case .videoRecordingFailed:
            return "MediaPicker could not record the video."
        case .captureSessionConfigurationFailed:
            return "MediaPicker could not configure the camera session."
        case .captureSessionStartFailed:
            return "MediaPicker could not start the camera session."
        case .captureSessionStopFailed:
            return "MediaPicker could not stop the camera session."
        case .captureSessionSwitchFailed:
            return "MediaPicker could not switch the active camera."
        case .unsupportedFlashMode:
            return "The active camera does not support the requested flash mode."
        case .unsupportedTorchMode:
            return "The active camera does not support the requested torch mode."
        case .cameraDeviceConfigurationFailed:
            return "MediaPicker could not configure the active camera device."
        case .cameraInUse:
            return "The camera is currently in use by another application."
        case .cameraUnavailable:
            return "The active camera is currently unavailable."
        case .captureSessionRuntimeFailed:
            return "The camera session encountered a runtime failure."
        case .mediaServicesResetRecoveryFailed:
            return "The camera could not recover after media services were reset."
        case .photoLibraryLoadingFailed:
            return "MediaPicker could not load the selected photo-library item."
        case .unsupportedFormat:
            return "The selected media format is not supported."
        case .unknownFailure:
            return "MediaPicker encountered an unexpected error."

        case .camera:
            return "camera"
        case .photoLibrary:
            return "photo library"
        case .cameraAndPhotoLibrary:
            return "camera and photo library"
        case .mediaSource:
            return "media source"

        case .cameraPermission:
            return "the camera"
        case .microphonePermission:
            return "the microphone"
        case .photoLibraryPermission:
            return "the photo library"

        case .emptySources:
            return "At least one media source must be enabled."
        case .unknownSource:
            return "The configuration contains an unknown media source."
        case .emptyMediaTypes:
            return "At least one media type must be enabled."
        case .unknownMediaType:
            return "The configuration contains an unknown media type."
        case .durationRequiresVideo:
            return "A maximum video duration requires video to be enabled."
        case .invalidVideoDuration:
            return "The maximum video duration must be a positive, finite number of seconds."
        case let .sourceUnavailable(source):
            return "The requested \(source) is unavailable on this device."
        case let .permissionDenied(permission):
            return "Permission to access \(permission) was denied."
        case let .invalidConfiguration(reason):
            return "The MediaPicker configuration is invalid: \(reason)"
        }
    }

}
