//
//  CameraPreviewOrientation.swift
//  MediaPicker
//
//  Created by Breno Lucas on 09/09/26.
//

#if os(iOS)
import UIKit

enum CameraPreviewOrientation {

    static func rotationAngle(for orientation: UIInterfaceOrientation) -> CGFloat {
        switch orientation {
        case .portrait:
            90
        case .portraitUpsideDown:
            270
        case .landscapeLeft:
            0
        case .landscapeRight:
            180
        case .unknown:
            90
        @unknown default:
            90
        }
    }

}
#endif
