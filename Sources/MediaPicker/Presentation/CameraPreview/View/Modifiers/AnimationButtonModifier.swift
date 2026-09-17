//
//  AnimationButtonModifier.swift
//  MediaPicker
//
//  Created by Breno Lucas on 14/09/26.
//

import SwiftUI

#if os(iOS)
struct AnimatedButtonModifier: ViewModifier {

    @ViewBuilder
    func body(content: Content) -> some View {
        content
            .buttonStyle(CameraControlButtonStyle())
    }

}

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

extension View {

    func animatedButton() -> some View {
        modifier(
            AnimatedButtonModifier()
        )
    }

}
#endif
