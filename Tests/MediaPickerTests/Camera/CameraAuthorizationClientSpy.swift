//
//  CameraAuthorizationClientSpy.swift
//  MediaPicker
//
//  Created by Breno Lucas on 02/09/26.
//
@testable import MediaPicker

actor CameraAuthorizationClientSpy: CameraAuthorizationClient {

    private var statuses: [CameraAuthorizationStatus]
    private(set) var requestCount = 0
    private(set) var checkedPermissions: [CaptureAuthorizationPermission] = []
    private(set) var requestedPermissions: [CaptureAuthorizationPermission] = []

    init(statuses: [CameraAuthorizationStatus]) {
        self.statuses = statuses
    }

    func currentStatus(
        for permission: CaptureAuthorizationPermission
    ) -> CameraAuthorizationStatus {
        checkedPermissions.append(permission)

        if statuses.count > 1 {
            return statuses.removeFirst()
        }

        return statuses[0]
    }

    func requestAccess(for permission: CaptureAuthorizationPermission) -> Bool {
        requestCount += 1
        requestedPermissions.append(permission)
        return true
    }

}
