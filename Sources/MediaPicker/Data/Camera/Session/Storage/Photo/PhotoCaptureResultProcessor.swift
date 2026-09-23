//
//  PhotoCaptureResultProcessor.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

import Foundation

/** Correlates captured bytes with their request before creating domain media. */
struct PhotoCaptureResultProcessor: Sendable {

    private let request: CameraPhotoCaptureRequest
    private let format: PhotoOutputFormat
    private let previewFraming: CameraPreviewFraming?
    private let encoder: PhotoDataEncoder
    private let fileStore: TemporaryMediaFileStore

    init(
        request: CameraPhotoCaptureRequest,
        format: PhotoOutputFormat,
        previewFraming: CameraPreviewFraming? = nil,
        encoder: PhotoDataEncoder = PhotoDataEncoder(),
        fileStore: TemporaryMediaFileStore = TemporaryMediaFileStore()
    ) {
        self.request = request
        self.format = format
        self.previewFraming = previewFraming
        self.encoder = encoder
        self.fileStore = fileStore
    }

    func process(data: Data?, requestID: Int64) throws -> CapturedMedia {
        guard matches(requestID), let data, data.isEmpty == false else {
            throw MediaPickerError.photoCaptureFailed
        }

        do {
            let photo = try encoder.encode(
                data,
                as: format,
                previewFraming: previewFraming
            )
            let fileURL = try fileStore.save(
                photo.data,
                fileName: String(request.id),
                fileExtension: photo.fileExtension
            )
            return CapturedMedia(
                mediaType: .photo,
                source: .camera,
                contentURL: fileURL
            )
        } catch {
            throw MediaPickerError.photoCaptureFailed
        }
    }

    func matches(_ requestID: Int64) -> Bool {
        requestID == request.id
    }

    func discard(_ media: CapturedMedia) {
        fileStore.remove(media.contentURL)
    }

}
