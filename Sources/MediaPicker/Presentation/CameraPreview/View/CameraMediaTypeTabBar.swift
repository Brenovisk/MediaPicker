//
//  CameraMediaTypeTabBar.swift
//  MediaPicker
//
//  Created by Breno Lucas on 22/09/26.
//

#if os(iOS)
import SwiftUI
import UIKit

/** Wraps the system tab bar used to select photo or video mode. */
struct CameraMediaTypeTabBar: View {

    let orientation: CameraPreviewOrientation
    let foregroundColor: Color
    let backgroundColor: Color

    @Binding var selection: MediaType

    var body: some View {
        NativeMediaTypeTabBar(
            selection: $selection,
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor
        )
        .frame(
            width: visualWidth,
            height: CameraPreviewConstants.Layout.mediaSelectorVisualHeight
        )
        .cameraControlRotation(
            orientation.valueTo(
                portrait: CameraPreviewConstants.Layout.mediaSelectorPortraitRotation,
                landscape: CameraPreviewConstants.Layout.mediaSelectorLandscapeRotation
            )
        )
        .frame(
            width: orientation.valueTo(
                portrait: reservedWidth,
                landscape: CameraPreviewConstants.Layout.mediaSelectorHeight
            ),
            height: orientation.valueTo(
                portrait: CameraPreviewConstants.Layout.mediaSelectorHeight,
                landscape: reservedWidth
            )
        )
        .padding(
            orientation.valueTo(
                portrait: .top,
                landscapeLeft: .leading,
                landscapeRight: .leading
            ),
            CameraPreviewConstants.Layout.mediaSelectorPadding
        )
    }

    private var reservedWidth: CGFloat {
        orientation.valueTo(
            portrait: CameraPreviewConstants.Layout.mediaSelectorWidth,
            landscape: CameraPreviewConstants.Layout.landscapeMediaSelectorWidth
        )
    }

    private var visualWidth: CGFloat {
        orientation.valueTo(
            portrait: CameraPreviewConstants.Layout.mediaSelectorVisualWidth,
            landscape: CameraPreviewConstants.Layout.landscapeMediaSelectorVisualWidth
        )
    }

}

private struct NativeMediaTypeTabBar: UIViewRepresentable {

    @Binding var selection: MediaType
    let foregroundColor: Color
    let backgroundColor: Color

    func makeCoordinator() -> Coordinator {
        Coordinator(selection: $selection)
    }

    func makeUIView(context: Context) -> UITabBar {
        let tabBar = UITabBar()

        tabBar.delegate = context.coordinator
        tabBar.itemPositioning = .fill
        tabBar.items = [
            tabItem(.video, title: MediaPickerConstants.Text.video.value),
            tabItem(.photo, title: MediaPickerConstants.Text.photo.value)
        ]

        tabBar.layoutMargins = .zero
        tabBar.insetsLayoutMarginsFromSafeArea = false

        return tabBar
    }

    func updateUIView(_ tabBar: UITabBar, context: Context) {
        context.coordinator.selection = $selection
        tabBar.selectedItem = tabBar.items?.first { item in
            item.tag == Int(selection.rawValue)
        }
        applyAppearance(to: tabBar)
    }

    private func tabItem(_ type: MediaType, title: String) -> UITabBarItem {
        let item = UITabBarItem(title: title, image: nil, tag: Int(type.rawValue))
        item.accessibilityLabel = title
        return item
    }

    private func applyAppearance(to tabBar: UITabBar) {
        let appearance = UITabBarAppearance()

        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(backgroundColor).withAlphaComponent(
            CameraPreviewConstants.Layout.mediaSelectorBackgroundOpacity
        )
        configure(appearance.stackedLayoutAppearance)
        configure(appearance.inlineLayoutAppearance)
        configure(appearance.compactInlineLayoutAppearance)

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .yellow
        tabBar.unselectedItemTintColor = UIColor(foregroundColor)

        tabBar.layer.cornerRadius = CameraPreviewConstants.Layout
            .mediaSelectorVisualHeight / 2

        tabBar.layer.cornerCurve = .continuous
        tabBar.layer.borderWidth = 1

        tabBar.layer.borderColor = UIColor(foregroundColor)
            .withAlphaComponent(
                CameraPreviewConstants.Layout.mediaSelectorBorderOpacity
            )
            .cgColor

        tabBar.clipsToBounds = false
    }

    private func configure(_ appearance: UITabBarItemAppearance) {
        let font = UIFont.systemFont(
            ofSize: CameraPreviewConstants.Layout.mediaSelectorFontSize,
            weight: .thin
        )

        let position = UIOffset(horizontal: .zero, vertical: -8)

        appearance.normal.titleTextAttributes = [
            .font: font,
            .foregroundColor: UIColor(foregroundColor)
        ]
        appearance.normal.titlePositionAdjustment = position

        appearance.selected.titleTextAttributes = [
            .font: font,
            .foregroundColor: UIColor.yellow
        ]
        appearance.selected.titlePositionAdjustment = position
    }

    @MainActor
    final class Coordinator: NSObject, UITabBarDelegate {

        var selection: Binding<MediaType>

        init(selection: Binding<MediaType>) {
            self.selection = selection
        }

        func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
            selection.wrappedValue = MediaType(rawValue: UInt8(item.tag))
        }

    }

}
#endif
