//
//  CameraPreviewRepresentable.swift
//  MediaPicker
//
//  Created by Breno Lucas on 09/09/26.
//

#if os(iOS)
import SwiftUI

struct CameraPreviewRepresentable: UIViewRepresentable {

    let previewSession: CaptureSessionReference
    let isMirrored: Bool
    let surface: CameraPreviewSurface

    func makeUIView(context: Context) -> CameraPreviewUIKitView {
        let view = CameraPreviewUIKitView(
            session: previewSession.session,
            frameStore: previewSession.frameStore
        )
        surface.attach(view)
        view.setMirroring(isMirrored)
        return view
    }

    func updateUIView(_ view: CameraPreviewUIKitView, context: Context) {
        view.setMirroring(isMirrored)
        view.updateVideoOrientation()
    }

    static func dismantleUIView(_ view: CameraPreviewUIKitView, coordinator: Void) {
        view.releaseFrozenFrame()
    }

}
#endif
