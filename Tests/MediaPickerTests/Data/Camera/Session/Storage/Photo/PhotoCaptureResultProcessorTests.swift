//
//  PhotoCaptureResultProcessorTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

import Foundation
import ImageIO
@testable import MediaPicker
import Testing
import UniformTypeIdentifiers

struct PhotoCaptureResultProcessorTests {

    @Test func matchingRequestCreatesCameraPhotoResult() throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let processor = makeProcessor(requestID: 42, directory: directory)

        let media = try processor.process(
            data: CapturedPhotoFixture.jpegData(),
            requestID: 42
        )

        #expect(media.mediaType == .photo)
        #expect(media.source == .camera)
        #expect(media.contentURL.pathExtension == "jpg")
        #expect(FileManager.default.isReadableFile(atPath: media.contentURL.path))
        #expect(try Data(contentsOf: media.contentURL) == CapturedPhotoFixture.jpegData())
    }

    @Test func pngSelectionConvertsAndReturnsReadablePNG() throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let processor = makeProcessor(
            requestID: 21,
            directory: directory,
            format: .png
        )

        let media = try processor.process(
            data: CapturedPhotoFixture.jpegData(),
            requestID: 21
        )

        #expect(media.contentURL.pathExtension == "png")
        #expect(FileManager.default.isReadableFile(atPath: media.contentURL.path))
        let data = try Data(contentsOf: media.contentURL)
        let source = CGImageSourceCreateWithData(data as CFData, nil)
        let typeIdentifier = source.flatMap(CGImageSourceGetType)
        #expect(typeIdentifier as String? == UTType.png.identifier)
    }

    @Test func savedPhotoMatchesLandscapeLivePreviewAspectRatio() throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let processor = makeProcessor(
            requestID: 22,
            directory: directory,
            previewFraming: CameraPreviewFraming(aspectRatio: 16.0 / 9.0)
        )

        let media = try processor.process(
            data: CapturedPhotoFixture.jpegData(width: 400, height: 300),
            requestID: 22
        )

        #expect(try imageSize(at: media.contentURL) == CGSize(width: 400, height: 225))
    }

    @Test func matchingAspectRatioDoesNotReencodeJPEG() throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let processor = makeProcessor(
            requestID: 24,
            directory: directory,
            previewFraming: CameraPreviewFraming(aspectRatio: 4.0 / 3.0)
        )
        let original = try CapturedPhotoFixture.jpegData(width: 400, height: 300)

        let media = try processor.process(data: original, requestID: 24)

        #expect(try Data(contentsOf: media.contentURL) == original)
    }

    @Test func aspectFillCropIsCenteredLikeTheLivePreview() {
        let crop = PhotoAspectRatioCropper.centeredCrop(
            in: CGRect(x: 0, y: 0, width: 400, height: 300),
            aspectRatio: 16.0 / 9.0
        )

        #expect(crop == CGRect(x: 0, y: 37, width: 400, height: 225))
    }

    @Test func normalizedViewportPreservesThePreviewCropPosition() throws {
        let normalizedCrop = try #require(
            CameraNormalizedRect(
                originX: 0.25,
                originY: 0,
                width: 0.5,
                height: 1
            )
        )
        let framing = try #require(
            CameraPreviewFraming(
                aspectRatio: 2.0 / 3.0,
                normalizedCrop: normalizedCrop
            )
        )

        let crop = PhotoAspectRatioCropper.cropRect(
            in: CGRect(x: 0, y: 0, width: 400, height: 300),
            framing: framing
        )

        #expect(crop == CGRect(x: 100, y: 0, width: 200, height: 300))
    }

    @Test func incompatibleNormalizedViewportFallsBackToVisibleAspectRatio() throws {
        let normalizedCrop = try #require(
            CameraNormalizedRect(
                originX: 0,
                originY: 0,
                width: 1,
                height: 1
            )
        )
        let framing = try #require(
            CameraPreviewFraming(
                aspectRatio: 16.0 / 9.0,
                normalizedCrop: normalizedCrop
            )
        )

        let crop = PhotoAspectRatioCropper.cropRect(
            in: CGRect(x: 0, y: 0, width: 400, height: 300),
            framing: framing
        )

        #expect(crop == CGRect(x: 0, y: 37, width: 400, height: 225))
    }

    @Test func savedPhotoCropsAfterApplyingCaptureOrientation() throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let processor = makeProcessor(
            requestID: 23,
            directory: directory,
            format: .png,
            previewFraming: CameraPreviewFraming(aspectRatio: 9.0 / 16.0)
        )

        let media = try processor.process(
            data: CapturedPhotoFixture.jpegData(
                width: 400,
                height: 300,
                orientation: 6
            ),
            requestID: 23
        )

        #expect(try imageSize(at: media.contentURL) == CGSize(width: 225, height: 400))
    }

    @Test func pngConversionPreservesCaptureOrientationWithoutCropping() throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let processor = makeProcessor(
            requestID: 25,
            directory: directory,
            format: .png,
            previewFraming: CameraPreviewFraming(aspectRatio: 3.0 / 4.0)
        )

        let media = try processor.process(
            data: CapturedPhotoFixture.jpegData(
                width: 400,
                height: 300,
                orientation: 6
            ),
            requestID: 25
        )

        #expect(try imageSize(at: media.contentURL) == CGSize(width: 300, height: 400))
    }

    @Test func callbackForDifferentRequestIsRejected() throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let processor = makeProcessor(requestID: 42, directory: directory)

        #expect(throws: MediaPickerError.photoCaptureFailed) {
            try processor.process(data: CapturedPhotoFixture.jpegData(), requestID: 43)
        }

        #expect(FileManager.default.fileExists(atPath: directory.path) == false)
    }

    @Test(arguments: [Data(), Data([0, 1, 2])])
    func emptyOrInvalidPhotoDataIsRejected(data: Data) {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let processor = makeProcessor(requestID: 1, directory: directory)

        #expect(throws: MediaPickerError.photoCaptureFailed) {
            try processor.process(data: data, requestID: 1)
        }

        #expect(FileManager.default.fileExists(atPath: directory.path) == false)
    }

    @Test func failedWriteRemovesPartialDestination() throws {
        let directory = temporaryDirectory()
        let partialURL = directory.appendingPathComponent("7.jpg")
        defer { try? FileManager.default.removeItem(at: directory) }
        try FileManager.default.createDirectory(
            at: partialURL,
            withIntermediateDirectories: true
        )
        let processor = makeProcessor(requestID: 7, directory: directory)

        #expect(throws: MediaPickerError.photoCaptureFailed) {
            try processor.process(data: CapturedPhotoFixture.jpegData(), requestID: 7)
        }

        #expect(FileManager.default.fileExists(atPath: partialURL.path) == false)
    }

    @Test func discardedProcessedResultRemovesItsTemporaryFile() throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let processor = makeProcessor(requestID: 9, directory: directory)
        let media = try processor.process(
            data: CapturedPhotoFixture.jpegData(),
            requestID: 9
        )

        processor.discard(media)

        #expect(FileManager.default.fileExists(atPath: media.contentURL.path) == false)
    }

    private func makeProcessor(
        requestID: Int64,
        directory: URL,
        format: PhotoOutputFormat = .jpeg,
        previewFraming: CameraPreviewFraming? = nil
    ) -> PhotoCaptureResultProcessor {
        PhotoCaptureResultProcessor(
            request: CameraPhotoCaptureRequest(id: requestID),
            format: format,
            previewFraming: previewFraming,
            fileStore: TemporaryMediaFileStore(directoryURL: directory)
        )
    }

    private func imageSize(at url: URL) throws -> CGSize {
        let data = try Data(contentsOf: url)
        let source = try #require(CGImageSourceCreateWithData(data as CFData, nil))
        let image = try #require(CGImageSourceCreateImageAtIndex(source, .zero, nil))
        return CGSize(width: image.width, height: image.height)
    }

    private func temporaryDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
    }

}
