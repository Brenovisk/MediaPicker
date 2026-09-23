//
//  CameraPreviewConstants.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

#if os(iOS)
import SwiftUI

enum CameraPreviewConstants {

    enum Layout {
        static let controlSize: CGFloat = 56
        static let topControlSize: CGFloat = 44
        static let topIconSize: CGFloat = 18
        static let shutterSize: CGFloat = 72
        static let shutterInnerInset: CGFloat = 6
        static let minimumTapTarget: CGFloat = 44
        static let horizontalPadding: CGFloat = 24
        static let verticalPadding: CGFloat = 24
        static let controlsSpacing: CGFloat = 24
        static let controlsMaximumWidth: CGFloat = 520
        static let landscapeControlsWidth = shutterSize
            + controlSize
            + (controlBarPadding * 3)
        static let portraitTopBarHeight: CGFloat = 56
        static let portraitControlsHeightWithSelector: CGFloat = 168
        static let portraitControlsHeightWithoutSelector: CGFloat = 88
        static let topBarRailWidth: CGFloat = 68
        static let controlBarPadding: CGFloat = 6
        static let progressSpacing: CGFloat = 8
        static let controlHorizontalPadding: CGFloat = 12
        static let reviewControlsSpacing: CGFloat = 16
        static let mediaSelectorSpacing: CGFloat = 24
        static let mediaSelectorWidth: CGFloat = 192
        static let landscapeMediaSelectorWidth: CGFloat = 172
        static let mediaSelectorHeight: CGFloat = 42
        static let mediaSelectorPadding: CGFloat = 24
        static let mediaSelectorVisualWidth: CGFloat = 224
        static let landscapeMediaSelectorVisualWidth: CGFloat = 224
        static let mediaSelectorVisualHeight: CGFloat = 24
        static let mediaSelectorPortraitRotation: CGFloat = 0
        static let mediaSelectorLandscapeRotation: CGFloat = -90
        static let mediaSelectorFontSize: CGFloat = 15
        static let mediaSelectorBackgroundOpacity = 0.88
        static let mediaSelectorBorderOpacity = 0.0
        static let reviewMaximumPixelSize = 2_048
        static let reviewBackgroundImageRadiusBlur = 24.0
        static let reviewBackgroundImageOpacity = 0.62
    }

    enum Motion {
        static let concealedBlurRadius: CGFloat = 14
        static let concealedOpacity = 0.58
        static let fullFlipDegrees = 180.0
        static let blurDuration = 0.08
        static let flipDuration = 0.3
        static let revealDuration = 0.5
        static let privacyBlurRadius: CGFloat = 20
        static let privacyBlurDuration = 0.8
        static let privacyRevealDuration = 0.2
        static let previewReadinessTimeout = 4.0
        static let readinessPollingInterval = 0.016
        static let pressedScale = 1.08
        static let pressedOpacity = 0.78
        static let buttonAnimationDuration = 0.16
        static let shutterFeedbackDuration = 0.12
        static let shutterFeedbackOpacity = 0.72
        static let reviewTransitionDuration = 0.12
        static let orientationTransitionDuration = 0.2
    }

    enum Icon {
        case close
        case confirmPhoto
        case flash(CameraFlashMode)
        case gallery
        case retakePhoto
        case shutter
        case switchCamera

        var systemName: String {
            switch self {
            case .close:
                return "xmark"
            case .confirmPhoto:
                return "checkmark"
            case .flash(.off):
                return "bolt.slash.fill"
            case .flash(.on):
                return "bolt.fill"
            case .flash(.auto):
                return "bolt.badge.automatic.fill"
            case .gallery:
                return "photo.on.rectangle"
            case .retakePhoto:
                if #available(iOS 18.0, *) {
                    return "arrow.trianglehead.2.clockwise.rotate.90.camera"
                }
                return "arrow.triangle.2.circlepath.camera"
            case .shutter:
                return "circle"
            case .switchCamera:
                return "arrow.triangle.2.circlepath"
            }
        }

        var image: Image {
            Image(systemName: systemName)
        }
    }

}
#endif
