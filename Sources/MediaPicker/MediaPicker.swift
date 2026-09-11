// The Swift Programming Language
// https://docs.swift.org/swift-book

public struct MediaPicker {

    private let authorizationClient: any CameraAuthorizationClient
    private let settingsOpener: any ApplicationSettingsOpening

    public init() {
        authorizationClient = SystemCameraAuthorizationClient()
        settingsOpener = SystemApplicationSettingsOpener()
    }

    init(
        authorizationClient: any CameraAuthorizationClient,
        settingsOpener: any ApplicationSettingsOpening
    ) {
        self.authorizationClient = authorizationClient
        self.settingsOpener = settingsOpener
    }

    /**
     Prepares capture access, requesting camera permission and, for video flows,
     microphone permission only when each permission has not been decided.

     - Throws: `MediaPickerError.permissionDenied(.camera)` when camera access is
       denied or restricted, or `MediaPickerError.unknown` if the system cannot
       resolve the authorization request.
    */
    @MainActor
    public func prepareCameraAccess(for mediaTypes: MediaType = .photoAndVideo) async throws {
        try await prepareAccess(for: .camera)

        if mediaTypes.contains(.video) {
            try await prepareAccess(for: .microphone)
        }
    }

}

// MARK: Helper Methods
extension MediaPicker {

    @MainActor
    private func prepareAccess(
        for permission: CaptureAuthorizationPermission
    ) async throws {
        let service = CameraAuthorizationService(
            permission: permission,
            client: authorizationClient
        )

        let currentStatus = await service.currentStatus()

        let publicPermission: MediaPickerError.Permission = switch permission {
        case .camera:
            .camera
        case .microphone:
            .microphone
        }

        if currentStatus == .denied {
            await settingsOpener.open()
            throw MediaPickerError.permissionDenied(publicPermission)
        }

        let status = await service.requestAccessIfNeeded()

        switch status {
        case .authorized:
            return
        case .denied:
            throw MediaPickerError.permissionDenied(publicPermission)
        case .restricted:
            throw MediaPickerError.permissionDenied(publicPermission)
        case .notDetermined:
            throw MediaPickerError.unknown
        }
    }

}
