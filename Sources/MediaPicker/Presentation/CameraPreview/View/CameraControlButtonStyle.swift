//
//  CameraControlButtonStyle.swift
//  MediaPicker
//
//  Created by Breno Lucas on 14/09/26.
//

#if os(iOS)
import SwiftUI

/** Gives camera utility controls consistent pressed feedback. */
struct CameraControlButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(
                configuration.isPressed
                    ? CameraPreviewConstants.Motion.pressedScale
                    : 1
            )
            .opacity(
                configuration.isPressed
                    ? CameraPreviewConstants.Motion.pressedOpacity
                    : 1
            )
            .animation(
                .snappy(
                    duration: CameraPreviewConstants.Motion.buttonAnimationDuration
                ),
                value: configuration.isPressed
            )
    }

}
#endif
