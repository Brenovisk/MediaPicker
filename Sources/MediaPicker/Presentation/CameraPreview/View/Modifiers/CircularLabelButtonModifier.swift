//
//  CircularLabelButtonModifier.swift
//  MediaPicker
//
//  Created by Breno Lucas on 17/09/26.
//

#if os(iOS)
import SwiftUI

/** Applies the standard circular camera-control appearance to an icon. */
struct CircularLabelButtonModifier: ViewModifier {

    let foregroundColor: Color
    let backgroundColor: Color
    let backgroundOpacity: Double
    let usesLiquidGlass: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if usesLiquidGlass {
            transparentControl(content)
        } else {
            baseControl(content)
        }
    }

    @ViewBuilder
    private func transparentControl(_ content: Content) -> some View {
        if #available(iOS 26.0, *) {
            baseControl(content)
                .glassEffect(.regular.interactive(), in: Circle())
        } else {
            baseControl(content)
                .background(.ultraThinMaterial, in: Circle())
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.14), lineWidth: 1)
                }
        }
    }

    private func baseControl(_ content: Content) -> some View {
        content
            .font(.title2)
            .foregroundStyle(foregroundColor)
            .frame(
                width: CameraPreviewConstants.Layout.controlSize,
                height: CameraPreviewConstants.Layout.controlSize
            )
            .background(
                backgroundColor.opacity(backgroundOpacity),
                in: Circle()
            )
            .contentShape(Circle())
    }

}

extension View {

    func circularLabelButton(
        foregroundColor: Color = .white,
        backgroundColor: Color = .clear,
        backgroundOpacity: Double = .zero,
        usesLiquidGlass: Bool = true
    ) -> some View {
        modifier(
            CircularLabelButtonModifier(
                foregroundColor: foregroundColor,
                backgroundColor: backgroundColor,
                backgroundOpacity: backgroundOpacity,
                usesLiquidGlass: usesLiquidGlass
            )
        )
    }

}
#endif
