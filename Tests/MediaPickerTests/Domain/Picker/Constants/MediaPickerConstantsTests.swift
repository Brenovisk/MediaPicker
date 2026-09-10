@testable import MediaPicker
import Testing

struct MediaPickerConstantsTests {

    @Test func dynamicErrorTextsInterpolateTheirContext() {
        #expect(
            MediaPickerConstants.Text.sourceUnavailable("camera").value ==
                "The requested camera is unavailable on this device."
        )
        #expect(
            MediaPickerConstants.Text.permissionDenied("the microphone").value ==
                "Permission to access the microphone was denied."
        )
        #expect(
            MediaPickerConstants.Text.invalidConfiguration("Invalid limit.").value ==
                "The MediaPicker configuration is invalid: Invalid limit."
        )
    }

    @Test func optionRawValuesRemainDistinct() {
        #expect(MediaPickerConstants.RawValue.photo != MediaPickerConstants.RawValue.video)
        #expect(
            MediaPickerConstants.RawValue.camera !=
                MediaPickerConstants.RawValue.photoLibrary
        )
    }

    @Test func minimumVideoDurationIsZero() {
        #expect(MediaPickerConstants.Number.minimumVideoDuration == .zero)
    }

}
