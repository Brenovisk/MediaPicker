//
//  CaptureSessionReference.swift
//  MediaPicker
//
//  Created by Breno Lucas on 09/09/26.
//

import AVFoundation

/**
 Shares the capture session identity with the preview without exposing mutation.

 Only `CaptureSessionStorage` changes the session. The preview layer keeps this
 reference solely to display the frames produced by that same session.
*/
final class CaptureSessionReference: @unchecked Sendable {

    let session = AVCaptureSession()
    let frameStore = CameraPreviewFrameStore()

}
