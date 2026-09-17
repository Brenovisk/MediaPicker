//
//  CameraPreviewTopBar.swift
//  MediaPicker
//
//  Created by Breno Lucas on 16/09/26.
//

#if os(iOS)
import SwiftUI

/** Places preparation feedback and cancellation above the preview. */
struct CameraPreviewTopBar: View {

    enum Placement {
        case top
        case side
    }

    let placement: Placement
    let canClose: Bool
    let showsPreparationIndicator: Bool
    let rotationDegrees: Double
    let onClose: () -> Void

    init(
        placement: Placement = .top,
        canClose: Bool,
        showsPreparationIndicator: Bool,
        rotationDegrees: Double = .zero,
        onClose: @escaping () -> Void
    ) {
        self.placement = placement
        self.canClose = canClose
        self.showsPreparationIndicator = showsPreparationIndicator
        self.rotationDegrees = rotationDegrees
        self.onClose = onClose
    }

    var body: some View {
        ZStack {
            preparationIndicator
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: preparationAlignment
                )

            closeButton
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: closeAlignment
                )
        }
        .padding(
            placement == .top ? .horizontal : .vertical,
            CameraPreviewConstants.Layout.horizontalPadding
        )
        .padding(
            placement == .top ? .vertical : .horizontal,
            CameraPreviewConstants.Layout.verticalPadding
        )
    }

    @ViewBuilder
    private var preparationIndicator: some View {
        if showsPreparationIndicator {
            ProgressView()
                .tint(.white)
                .frame(
                    width: CameraPreviewConstants.Layout.minimumTapTarget,
                    height: CameraPreviewConstants.Layout.minimumTapTarget
                )
                .rotationEffect(.degrees(rotationDegrees))
                .accessibilityLabel(MediaPickerConstants.Text.preparingCamera.value)
        }
    }

    private var closeButton: some View {
        Button(action: onClose) {
            CameraPreviewConstants.Icon.close.styledImage
        }
        .buttonStyle(CameraControlButtonStyle())
        .disabled(canClose == false)
        .rotationEffect(.degrees(rotationDegrees))
        .accessibilityLabel(MediaPickerConstants.Text.closeCamera.value)
    }

    private var preparationAlignment: Alignment {
        placement == .top ? .bottom : .top
    }

    private var closeAlignment: Alignment {
        placement == .top ? .bottomTrailing : .topTrailing
    }

}
#endif
