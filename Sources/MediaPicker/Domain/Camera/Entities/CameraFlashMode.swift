//
//  CameraFlashMode.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

enum CameraFlashMode: Sendable, Equatable, Hashable, CaseIterable {

    case off
    // Matches AVFoundation's established mode terminology.
    // swiftlint:disable:next identifier_name
    case on
    case auto

}
