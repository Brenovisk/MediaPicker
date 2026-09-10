//
//  ApplicationSettingsOpener.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@MainActor
protocol ApplicationSettingsOpening: Sendable {
    func open() async
}

struct SystemApplicationSettingsOpener: ApplicationSettingsOpening {

    func open() async {
        #if canImport(UIKit)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            await UIApplication.shared.open(url)
        }
        #elseif canImport(AppKit)
        let url = URL(fileURLWithPath: "/System/Applications/System Settings.app")
        NSWorkspace.shared.open(url)
        #endif
    }

}
