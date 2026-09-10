//
//  CameraLightingCapabilitiesTests.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

@testable import MediaPicker
import Testing

struct CameraLightingCapabilitiesTests {

    @Test func unavailableCapabilitiesExposeNoLightingModes() {
        let capabilities = CameraLightingCapabilities.unavailable

        #expect(capabilities.flashModes.isEmpty)
        #expect(capabilities.torchModes.isEmpty)
        #expect(capabilities.supportsFlash == false)
        #expect(capabilities.supportsTorch == false)
    }

    @Test func supportedModesAreExposedWithoutFrameworkTypes() {
        let capabilities = CameraLightingCapabilities(
            flashModes: [.off, .on, .auto],
            torchModes: [.off, .on]
        )

        #expect(capabilities.supportsFlash)
        #expect(capabilities.supportsTorch)
        #expect(capabilities.flashModes == [.off, .on, .auto])
        #expect(capabilities.torchModes == [.off, .on])
    }

}
