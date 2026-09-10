import AVFoundation

protocol CameraAuthorizationClient: Sendable {

    func currentStatus(
        for permission: CaptureAuthorizationPermission
    ) async -> CameraAuthorizationStatus

    func requestAccess(
        for permission: CaptureAuthorizationPermission
    ) async -> Bool

}

struct SystemCameraAuthorizationClient: CameraAuthorizationClient {

    func currentStatus(
        for permission: CaptureAuthorizationPermission
    ) async -> CameraAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: permission.mediaType)
            .cameraAuthorizationStatus
    }

    func requestAccess(
        for permission: CaptureAuthorizationPermission
    ) async -> Bool {
        await AVCaptureDevice.requestAccess(for: permission.mediaType)
    }

}

private extension AVAuthorizationStatus {

    var cameraAuthorizationStatus: CameraAuthorizationStatus {
        switch self {
        case .notDetermined:
            .notDetermined
        case .authorized:
            .authorized
        case .denied:
            .denied
        case .restricted:
            .restricted
        @unknown default:
            .restricted
        }
    }

}
