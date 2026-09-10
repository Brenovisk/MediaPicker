//
//  CameraDeviceStub.swift
//  MediaPicker
//
//  Created by Breno Lucas on 09/09/26.
//

@testable import MediaPicker

struct CameraDeviceStub: CameraDeviceCandidate {

    let cameraDeviceIdentifier: String
    let cameraPosition: CameraPosition
    let cameraDeviceKind: CameraDeviceKind

    init(
        identifier: String,
        position: CameraPosition,
        kind: CameraDeviceKind
    ) {
        cameraDeviceIdentifier = identifier
        cameraPosition = position
        cameraDeviceKind = kind
    }

}
