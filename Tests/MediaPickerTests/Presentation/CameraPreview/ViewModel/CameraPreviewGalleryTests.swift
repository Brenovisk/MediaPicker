//
//  CameraPreviewGalleryTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 18/09/26.
//

#if os(iOS)
import Foundation
@testable import MediaPicker
import Testing

@MainActor
struct CameraPreviewGalleryTests {

    @Test func gallerySelectionEntersReviewAndCanBeRetaken() throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let fileStore = TemporaryMediaFileStore(directoryURL: directory)
        let viewModel = makeViewModel(
            fileStore: fileStore,
            showsReview: true
        )

        #expect(viewModel.canSelectLibraryPhoto)
        let media = try viewModel.selectLibraryPhoto(CapturedPhotoFixture.jpegData())
        #expect(media.source == .photoLibrary)
        #expect(viewModel.capturedMedia == media)
        #expect(viewModel.canSelectLibraryPhoto == false)
        #expect(FileManager.default.fileExists(atPath: media.contentURL.path))

        viewModel.recapturePhoto()
        #expect(viewModel.capturedMedia == nil)
        #expect(FileManager.default.fileExists(atPath: media.contentURL.path) == false)
    }

    @Test func disabledReviewReturnsGalleryResultImmediately() throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let viewModel = makeViewModel(
            fileStore: TemporaryMediaFileStore(directoryURL: directory),
            showsReview: false
        )

        let media = try viewModel.selectLibraryPhoto(CapturedPhotoFixture.jpegData())

        #expect(media.source == .photoLibrary)
        #expect(viewModel.capturedMedia == nil)
        #expect(viewModel.isReviewingPhoto == false)
    }

    private func makeViewModel(
        fileStore: TemporaryMediaFileStore,
        showsReview: Bool
    ) -> CameraPreviewViewModel {
        CameraPreviewViewModel(
            initialPosition: .back,
            showsReview: showsReview,
            dependencies: .make(
                cameraSession: CaptureSessionService(
                    operations: CaptureSessionClientSpy().operations
                ),
                mediaDiscarder: fileStore,
                photoLibraryImporter: PhotoLibraryPhotoImporter(fileStore: fileStore)
            )
        )
    }

    private func temporaryDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
    }

}
#endif
