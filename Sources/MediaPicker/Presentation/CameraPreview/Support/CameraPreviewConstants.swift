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
        static let switchButtonSize: CGFloat = 56
        static let horizontalPadding: CGFloat = 32
        static let bottomPadding: CGFloat = 64
    }

    enum Motion {
        static let concealedBlurRadius: CGFloat = 14
        static let concealedOpacity = 0.58
        static let fullFlipDegrees = 180.0
        static let blurDuration = 0.08
        static let flipDuration = 0.3
        static let revealDuration = 0.5
        static let previewReadinessTimeout = 4.0
        static let readinessPollingInterval = 0.016
        static let pressedScale = 1.08
        static let pressedOpacity = 0.78
        static let buttonAnimationDuration = 0.16
    }

    enum Icon {
        case switchCamera

        var systemName: String {
            switch self {
            case .switchCamera:
                "arrow.triangle.2.circlepath.camera"
            }
        }

        var image: Image {
            Image(systemName: systemName)
        }

        @ViewBuilder
        var styledImage: some View {
            if #available(iOS 26.0, *) {
                baseImage
                    .glassEffect(.regular.interactive(), in: Circle())
            } else {
                baseImage
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.14), lineWidth: 1)
                    }
            }
        }

        private var baseImage: some View {
            image
                .font(.title2)
                .foregroundStyle(.white)
                .frame(
                    width: CameraPreviewConstants.Layout.switchButtonSize,
                    height: CameraPreviewConstants.Layout.switchButtonSize
                )
                .contentShape(Circle())
        }
    }

}
#endif
