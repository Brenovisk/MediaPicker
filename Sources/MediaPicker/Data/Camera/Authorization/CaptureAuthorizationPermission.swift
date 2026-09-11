//
//  CaptureAuthorizationPermission.swift
//  MediaPicker
//
//  Created by Breno Lucas on 02/09/26.
//

import AVFoundation

enum CaptureAuthorizationPermission: Sendable, Equatable {
    case camera
    case microphone

    var mediaType: AVMediaType {
        switch self {
        case .camera:
            .video
        case .microphone:
            .audio
        }
    }
}
