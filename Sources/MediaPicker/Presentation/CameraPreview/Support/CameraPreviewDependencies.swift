//
//  CameraPreviewDependencies.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

#if os(iOS)
@MainActor
struct CameraPreviewDependencies {

    let previewSession: CaptureSessionReference?
    let previewSurface: CameraPreviewSurface
    let openCamera: OpenCameraUseCase
    let closeCamera: CloseCameraUseCase
    let updateCameraSession: UpdateCameraSessionUseCase
    let switchCamera: SwitchCameraUseCase
    let capturePhoto: CapturePhotoUseCase
    let loadPhotoPreview: LoadPhotoPreviewUseCase
    let discardCapturedMedia: DiscardCapturedMediaUseCase
    let importPhotoFromLibrary: ImportPhotoFromLibraryUseCase
    let setFlashMode: SetCameraFlashModeUseCase
    let setTorchMode: SetCameraTorchModeUseCase

    static func live() -> CameraPreviewDependencies {
        make(cameraSession: CaptureSessionService())
    }

    static func make(
        cameraSession: CaptureSessionService,
        previewSurface: CameraPreviewSurface? = nil,
        mediaDiscarder: any CapturedMediaDiscarding = TemporaryMediaFileStore(),
        photoPreviewLoader: any PhotoPreviewLoading = ImageIOPhotoPreviewLoader(),
        photoLibraryImporter: any PhotoLibraryImporting = PhotoLibraryPhotoImporter()
    ) -> CameraPreviewDependencies {
        let previewSurface = previewSurface ?? CameraPreviewSurface()
        let openCameraUseCase = OpenCameraUseCase(cameraSession: cameraSession)

        let closeCameraUseCase = CloseCameraUseCase(cameraSession: cameraSession)

        let updateCameraSessionUseCase = UpdateCameraSessionUseCase(
            cameraSession: cameraSession
        )

        let switchCameraUseCase = SwitchCameraUseCase(
            cameraSession: cameraSession,
            frameReadiness: previewSurface
        )

        return CameraPreviewDependencies(
            previewSession: cameraSession.previewSession,
            previewSurface: previewSurface,
            openCamera: openCameraUseCase,
            closeCamera: closeCameraUseCase,
            updateCameraSession: updateCameraSessionUseCase,
            switchCamera: switchCameraUseCase,
            capturePhoto: CapturePhotoUseCase(cameraSession: cameraSession),
            loadPhotoPreview: LoadPhotoPreviewUseCase(loader: photoPreviewLoader),
            discardCapturedMedia: DiscardCapturedMediaUseCase(
                mediaDiscarder: mediaDiscarder
            ),
            importPhotoFromLibrary: ImportPhotoFromLibraryUseCase(
                importer: photoLibraryImporter
            ),
            setFlashMode: SetCameraFlashModeUseCase(cameraSession: cameraSession),
            setTorchMode: SetCameraTorchModeUseCase(cameraSession: cameraSession)
        )
    }

}
#endif
