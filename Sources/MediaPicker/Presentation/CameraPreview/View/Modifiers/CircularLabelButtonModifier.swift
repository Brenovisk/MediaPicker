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
    let size: CGFloat

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
                width: size,
                height: size
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
        usesLiquidGlass: Bool = true,
        size: CGFloat = CameraPreviewConstants.Layout.controlSize
    ) -> some View {
        modifier(
            CircularLabelButtonModifier(
                foregroundColor: foregroundColor,
                backgroundColor: backgroundColor,
                backgroundOpacity: backgroundOpacity,
                usesLiquidGlass: usesLiquidGlass,
                size: size
            )
        )
    }

    /** Centers a smaller unframed icon within an accessible top-bar tap target. */
    func topCameraControlLabel(foregroundColor: Color) -> some View {
        modifier(TopCameraControlLabelModifier(foregroundColor: foregroundColor))
    }

    /** Keeps control content upright while the device changes orientation. */
    func cameraControlRotation(_ degrees: Double) -> some View {
        rotationEffect(.degrees(degrees))
            .animation(
                .easeInOut(
                    duration: CameraPreviewConstants.Motion.orientationTransitionDuration
                ),
                value: degrees
            )
    }

}

/** Rotates only a control's glyph while its container keeps a stable frame. */
struct CameraControlIcon: View {

    let systemName: String
    var rotationDegrees: Double

    nonisolated init(systemName: String, rotationDegrees: Double = .zero) {
        self.systemName = systemName
        self.rotationDegrees = rotationDegrees
    }

    var body: some View {
        Image(systemName: systemName)
            .cameraControlRotation(rotationDegrees)
    }

}

private struct TopCameraControlLabelModifier: ViewModifier {

    let foregroundColor: Color

    func body(content: Content) -> some View {
        content
            .font(.system(size: CameraPreviewConstants.Layout.topIconSize))
            .foregroundStyle(foregroundColor)
            .frame(
                width: CameraPreviewConstants.Layout.topControlSize,
                height: CameraPreviewConstants.Layout.topControlSize
            )
            .contentShape(Rectangle())
    }

}
#endif
