/**
 Coordinates authorization for a capture permission, such as the camera or
 microphone, without exposing AVFoundation types to the rest of the module.

 Use `currentStatus()` to inspect the permission without displaying a system
 prompt. `requestAccessIfNeeded()` requests access only when the current state
 is `notDetermined`; authorized, denied, and restricted states are returned
 unchanged.

 The system client is used by default. A different client can be injected to
 test authorization flows without accessing real devices or showing prompts.

 This service does not update UI state. Callers that publish its result to the
 interface must perform those updates on the main actor.
*/
struct CameraAuthorizationService: Sendable {

    private let client: any CameraAuthorizationClient
    private let permission: CaptureAuthorizationPermission

    init(
        permission: CaptureAuthorizationPermission = .camera,
        client: any CameraAuthorizationClient = SystemCameraAuthorizationClient()
    ) {
        self.permission = permission
        self.client = client
    }

    /// Returns the current camera permission without displaying a system prompt.
    func currentStatus() async -> CameraAuthorizationStatus {
        await client.currentStatus(for: permission)
    }

    /// Requests camera permission only when the user has not made a choice yet.
    func requestAccessIfNeeded() async -> CameraAuthorizationStatus {
        let status = await currentStatus()

        switch status {
        case .notDetermined:
            _ = await client.requestAccess(for: permission)
            return await currentStatus()
        case .authorized, .denied, .restricted:
            return status
        }
    }

}
