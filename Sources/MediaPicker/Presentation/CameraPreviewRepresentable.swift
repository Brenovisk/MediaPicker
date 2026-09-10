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

    func makeUIView(context: Context) -> CameraPreviewView {
        CameraPreviewView(session: previewSession.session)
    }

    func updateUIView(_ view: CameraPreviewView, context: Context) {
        view.updateVideoOrientation()
    }

}
#endif
