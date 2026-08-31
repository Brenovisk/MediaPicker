import MediaPicker
import Testing

struct MediaSourceTests {

    @Test func cameraCanBeConfiguredIndependently() {
        let sources: MediaSource = .camera

        #expect(sources.contains(.camera))
        #expect(!sources.contains(.photoLibrary))
    }

    @Test func photoLibraryCanBeConfiguredIndependently() {
        let sources: MediaSource = .photoLibrary

        #expect(sources.contains(.photoLibrary))
        #expect(!sources.contains(.camera))
    }

    @Test func cameraAndPhotoLibraryCanBeConfiguredTogether() {
        let sources: MediaSource = [.camera, .photoLibrary]

        #expect(sources == .cameraAndPhotoLibrary)
    }

    @Test func enabledSourcesHavePredictablePresentationOrder() {
        #expect(MediaSource.cameraAndPhotoLibrary.orderedSources == [.camera, .photoLibrary])
        #expect(MediaSource.photoLibrary.orderedSources == [.photoLibrary])
        #expect(MediaSource.camera.orderedSources == [.camera])
    }

    @Test func unsupportedSourcesCanBeDetectedBeforePresentation() {
        let requestedSources: MediaSource = .cameraAndPhotoLibrary
        let availableSources: MediaSource = .camera

        #expect(
            requestedSources.unsupportedSources(given: availableSources) == .photoLibrary
        )
        #expect(!requestedSources.isSupported(given: availableSources))
    }

    @Test func requestedSourcesAreSupportedWhenEverySourceIsAvailable() {
        let sources: MediaSource = .cameraAndPhotoLibrary

        #expect(sources.unsupportedSources(given: .cameraAndPhotoLibrary).isEmpty)
        #expect(sources.isSupported(given: .cameraAndPhotoLibrary))
    }

    @Test func mediaSourceIsSendable() {
        requireSendable(MediaSource.cameraAndPhotoLibrary)
    }

    private func requireSendable<T: Sendable>(_: T) {}

}
