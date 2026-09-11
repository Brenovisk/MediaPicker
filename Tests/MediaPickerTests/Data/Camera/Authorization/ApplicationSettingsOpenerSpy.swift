//
//  ApplicationSettingsOpenerSpy.swift
//  MediaPicker
//
//  Created by Breno Lucas on 02/09/26.
//
@testable import MediaPicker

@MainActor
final class ApplicationSettingsOpenerSpy: ApplicationSettingsOpening {

    private(set) var openCount = 0

    func open() {
        openCount += 1
    }

}
