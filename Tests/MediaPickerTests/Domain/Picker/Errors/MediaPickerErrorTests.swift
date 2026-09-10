import Foundation
@testable import MediaPicker
import Testing

struct MediaPickerErrorTests {

    @Test func majorFailureFlowsHaveDistinctCases() {
        let errors: [MediaPickerError] = [
            .sourceUnavailable(.camera),
            .permissionDenied(.camera),
            .invalidConfiguration("No media source was enabled."),
            .photoCaptureFailed,
            .videoRecordingFailed,
            .captureSessionConfigurationFailed,
            .captureSessionStartFailed,
            .captureSessionStopFailed,
            .captureSessionSwitchFailed,
            .unsupportedFlashMode,
            .unsupportedTorchMode,
            .cameraDeviceConfigurationFailed,
            .photoLibraryLoadingFailed,
            .unsupportedFormat,
            .unknown
        ]

        #expect(Set(errors).count == errors.count)
    }

    @Test func everyFailureProvidesADiagnosticDescription() {
        let errors: [MediaPickerError] = [
            .sourceUnavailable(.cameraAndPhotoLibrary),
            .permissionDenied(.microphone),
            .invalidConfiguration("No media type was enabled."),
            .photoCaptureFailed,
            .videoRecordingFailed,
            .captureSessionConfigurationFailed,
            .captureSessionStartFailed,
            .captureSessionStopFailed,
            .captureSessionSwitchFailed,
            .unsupportedFlashMode,
            .unsupportedTorchMode,
            .cameraDeviceConfigurationFailed,
            .photoLibraryLoadingFailed,
            .unsupportedFormat,
            .unknown
        ]

        for error in errors {
            #expect(error.errorDescription?.isEmpty == false)
        }
    }

    @Test func configurationDescriptionIncludesTheSpecificReason() {
        let error = MediaPickerError.invalidConfiguration(
            "At least one media source is required."
        )

        #expect(error.errorDescription?.contains("At least one media source is required.") == true)
    }

    @Test func deniedPermissionDescriptionIdentifiesThePermission() {
        let cameraError = MediaPickerError.permissionDenied(.camera)
        let microphoneError = MediaPickerError.permissionDenied(.microphone)
        let libraryError = MediaPickerError.permissionDenied(.photoLibrary)

        #expect(cameraError.errorDescription?.contains("camera") == true)
        #expect(microphoneError.errorDescription?.contains("microphone") == true)
        #expect(libraryError.errorDescription?.contains("photo library") == true)
    }

    @Test func mediaPickerErrorIsSendable() {
        requireSendable(MediaPickerError.unknown)
    }

}

// MARK: Helper Methods
extension MediaPickerErrorTests {

    private func requireSendable<T: Sendable>(_: T) {}

}
