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
        format: PhotoOutputFormat = .jpeg
    ) -> PhotoCaptureResultProcessor {
        PhotoCaptureResultProcessor(
            request: CameraPhotoCaptureRequest(id: requestID),
            format: format,
            fileStore: TemporaryMediaFileStore(directoryURL: directory)
        )
    }

    private func temporaryDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
    }

}
