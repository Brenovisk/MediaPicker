//
//  CameraPreviewControls.swift
//  MediaPicker
//
//  Created by Breno Lucas on 14/09/26.
//

#if os(iOS)
import PhotosUI
import SwiftUI

/** Keeps the shutter and lower actions compact without reserving hidden-control slots. */
struct CameraPreviewControls: View {

    let orientation: CameraPreviewOrientation
    let options: CameraPreviewControlOptions
    let canClose: Bool
    let canCapturePhoto: Bool
    let canSelectLibraryPhoto: Bool
    let onClose: () -> Void
    let onCapture: () -> Void
    @Binding var selectedMediaType: MediaType
    @Binding var galleryItem: PhotosPickerItem?

    var body: some View {
        Group {
            if orientation == .portrait {
                portraitControls
            } else {
                landscapeControls
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(
            .horizontal,
            orientation == .portrait
                ? CameraPreviewConstants.Layout.horizontalPadding
                : CameraPreviewConstants.Layout.controlBarPadding
        )
        .padding(.vertical, CameraPreviewConstants.Layout.controlBarPadding)
        .background(options.backgroundColor.opacity(0.4))
        .background(.ultraThinMaterial)
    }

    private var landscapeControls: some View {
        HStack(spacing: CameraPreviewConstants.Layout.controlBarPadding) {
            if options.showsMediaSelector {
                landscapeShutterColumn
                landscapeActionsColumn
            } else {
                landscapeShutterActionsColumn
            }
        }
    }

    private var landscapeShutterColumn: some View {
        shutterButton
            .frame(width: CameraPreviewConstants.Layout.shutterSize)
            .frame(maxHeight: .infinity, alignment: .center)
    }

    private var landscapeActionsColumn: some View {
        ZStack {
            mediaSelector

            closeButton
                .frame(maxHeight: .infinity, alignment: .bottom)

            galleryButton
                .frame(maxHeight: .infinity, alignment: .top)
        }
    }

    private var landscapeShutterActionsColumn: some View {
        ZStack {
            shutterButton
                .frame(width: CameraPreviewConstants.Layout.shutterSize)
                .frame(maxHeight: .infinity, alignment: .center)

            closeButton
                .frame(maxHeight: .infinity, alignment: .bottom)

            galleryButton
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(width: CameraPreviewConstants.Layout.controlSize)
        .frame(maxHeight: .infinity)
    }

    @ViewBuilder
    private var portraitControls: some View {
        if options.showsMediaSelector {
            VStack {
                shutterButton
                sideActions
            }
        } else {
            ZStack {
                shutterButton
                sideActions
            }
        }
    }

    private var sideActions: some View {
        ZStack {
            mediaSelector

            HStack {
                closeButton
                Spacer(minLength: .zero)
                galleryButton
            }
        }
    }

    private var closeButton: some View {
        Button(action: onClose) {
            CameraControlIcon(
                systemName: CameraPreviewConstants.Icon.close.systemName
            )
                .circularLabelButton(
                    foregroundColor: options.foregroundColor,
                    backgroundColor: options.backgroundColor
                )
        }
        .animatedButton()
        .disabled(canClose == false)
        .accessibilityLabel(MediaPickerConstants.Text.closeCamera.value)
    }

    @ViewBuilder
    private var mediaSelector: some View {
        if options.showsMediaSelector {
            CameraMediaTypeTabBar(
                orientation: orientation,
                foregroundColor: options.foregroundColor,
                backgroundColor: options.backgroundColor,
                selection: $selectedMediaType
            )
        }
    }

    @ViewBuilder
    private var galleryButton: some View {
        if options.canChoosePhotoFromGallery {
            PhotosPicker(selection: $galleryItem, matching: .images) {
                CameraControlIcon(
                    systemName: CameraPreviewConstants.Icon.gallery.systemName
                )
            }
            .circularLabelButton(
                foregroundColor: options.foregroundColor,
                backgroundColor: options.backgroundColor
            )
            .animatedButton()
            .disabled(canSelectLibraryPhoto == false)
            .accessibilityLabel(MediaPickerConstants.Text.gallery.value)
        }
    }

    private var shutterButton: some View {
        Button(action: onCapture) {
            CameraShutterButtonLabel(
                innerColor: selectedMediaType == .video
                    ? .red
                    : options.foregroundColor,
                ringColor: options.foregroundColor
            )
        }
        .animatedButton()
        .disabled(
            canCapturePhoto == false
                || options.canCapturePhoto(in: selectedMediaType) == false
        )
        .accessibilityLabel(
            selectedMediaType == .photo
                ? MediaPickerConstants.Text.capturePhoto.value
                : MediaPickerConstants.Text.videoUnavailable.value
        )
    }

}

private struct CameraShutterButtonLabel: View {

    let innerColor: Color
    let ringColor: Color

    var body: some View {
        if #available(iOS 26.0, *) {
            shutter.glassEffect(.regular.interactive(), in: Circle())
        } else {
            shutter.background(.ultraThinMaterial, in: Circle())
        }
    }

    private var shutter: some View {
        Circle()
            .fill(innerColor.opacity(0.96))
            .padding(CameraPreviewConstants.Layout.shutterInnerInset)
            .overlay {
                Circle().stroke(ringColor.opacity(0.9), lineWidth: 3)
            }
            .frame(
                width: CameraPreviewConstants.Layout.shutterSize,
                height: CameraPreviewConstants.Layout.shutterSize
            )
            .contentShape(Circle())
    }

}
#endif
