@testable import MediaPicker
import Testing

struct CameraAuthorizationServiceTests {

    @Test func currentStatusDoesNotRequestAccess() async {
        let client = CameraAuthorizationClientSpy(statuses: [.denied])
        let service = CameraAuthorizationService(client: client)

        let status = await service.currentStatus()

        #expect(status == .denied)
        #expect(await client.requestCount == 0)
    }

    @Test func accessIsRequestedWhenStatusIsNotDetermined() async {
        let client = CameraAuthorizationClientSpy(
            statuses: [.notDetermined, .authorized]
        )
        let service = CameraAuthorizationService(client: client)

        let status = await service.requestAccessIfNeeded()

        #expect(status == .authorized)
        #expect(await client.requestCount == 1)
    }

    @Test(arguments: [
        CameraAuthorizationStatus.authorized,
        .denied,
        .restricted
    ])
    func accessIsNotRequestedForDeterminedStatuses(
        status: CameraAuthorizationStatus
    ) async {
        let client = CameraAuthorizationClientSpy(statuses: [status])
        let service = CameraAuthorizationService(client: client)

        let result = await service.requestAccessIfNeeded()

        #expect(result == status)
        #expect(await client.requestCount == 0)
    }

    @Test func deniedAndRestrictedAreDistinctStates() {
        #expect(CameraAuthorizationStatus.denied != .restricted)
    }

    @Test func microphoneAuthorizationUsesTheMicrophonePermission() async {
        let client = CameraAuthorizationClientSpy(
            statuses: [.notDetermined, .authorized]
        )
        let service = CameraAuthorizationService(
            permission: .microphone,
            client: client
        )

        let status = await service.requestAccessIfNeeded()

        #expect(status == .authorized)
        #expect(await client.checkedPermissions == [.microphone, .microphone])
        #expect(await client.requestedPermissions == [.microphone])
    }

    @Test func authorizationTypesAreSendable() {
        requireSendable(CameraAuthorizationStatus.authorized)
        requireSendable(CameraAuthorizationService())
    }

    @Test @MainActor func deniedPermissionOpensSettingsOnANewAttempt() async {
        let client = CameraAuthorizationClientSpy(statuses: [.denied])
        let settingsOpener = ApplicationSettingsOpenerSpy()
        let picker = MediaPicker(
            authorizationClient: client,
            settingsOpener: settingsOpener
        )

        await #expect(throws: MediaPickerError.permissionDenied(.camera)) {
            try await picker.prepareCameraAccess(for: .photo)
        }
        #expect(settingsOpener.openCount == 1)
        #expect(await client.requestCount == 0)
    }

    @Test @MainActor func firstDenialDoesNotImmediatelyOpenSettings() async {
        let client = CameraAuthorizationClientSpy(
            statuses: [.notDetermined, .notDetermined, .denied]
        )
        let settingsOpener = ApplicationSettingsOpenerSpy()
        let picker = MediaPicker(
            authorizationClient: client,
            settingsOpener: settingsOpener
        )

        await #expect(throws: MediaPickerError.permissionDenied(.camera)) {
            try await picker.prepareCameraAccess(for: .photo)
        }
        #expect(settingsOpener.openCount == 0)
        #expect(await client.requestCount == 1)
    }

}

private extension CameraAuthorizationServiceTests {

    func requireSendable<T: Sendable>(_: T) {}

}
