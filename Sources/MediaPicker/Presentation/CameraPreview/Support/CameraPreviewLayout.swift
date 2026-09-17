//
//  CameraPreviewLayout.swift
//  MediaPicker
//
//  Created by Breno Lucas on 17/09/26.
//

#if os(iOS)
import SwiftUI

/**
 Places the camera preview and its controls without changing their structural identity.

 Keeping the same three subviews while the device rotates prevents SwiftUI from rebuilding
 the UIKit camera preview and its `AVCaptureVideoPreviewLayer`.
 */
struct CameraPreviewLayout: Layout {

    let orientation: CameraPreviewOrientation

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        guard subviews.count == SubviewIndex.allCases.count else { return }

        switch orientation {
        case .portrait:
            placePortraitSubviews(in: bounds, subviews: subviews)
        case .landscapeLeft, .landscapeRight:
            placeLandscapeSubviews(
                in: bounds,
                cancelOnLeadingEdge: orientation.topBarOnLeadingEdge,
                subviews: subviews
            )
        }
    }

    private func placePortraitSubviews(in bounds: CGRect, subviews: Subviews) {
        let topBarHeight = CameraPreviewConstants.Layout.portraitTopBarHeight
        let controlsHeight = CameraPreviewConstants.Layout.portraitControlsHeight
        let previewHeight = max(.zero, bounds.height - topBarHeight - controlsHeight)

        place(
            subviews[SubviewIndex.topBar.rawValue],
            in: CGRect(
                x: bounds.minX,
                y: bounds.minY,
                width: bounds.width,
                height: topBarHeight
            )
        )
        place(
            subviews[SubviewIndex.preview.rawValue],
            in: CGRect(
                x: bounds.minX,
                y: bounds.minY + topBarHeight,
                width: bounds.width,
                height: previewHeight
            )
        )
        place(
            subviews[SubviewIndex.controls.rawValue],
            in: CGRect(
                x: bounds.minX,
                y: bounds.maxY - controlsHeight,
                width: bounds.width,
                height: controlsHeight
            )
        )
    }

    private func placeLandscapeSubviews(
        in bounds: CGRect,
        cancelOnLeadingEdge: Bool,
        subviews: Subviews
    ) {
        let railWidth = min(
            CameraPreviewConstants.Layout.landscapeControlsWidth,
            bounds.width / 3
        )
        let leadingSubview = cancelOnLeadingEdge
            ? subviews[SubviewIndex.topBar.rawValue]
            : subviews[SubviewIndex.controls.rawValue]

        let trailingSubview = cancelOnLeadingEdge
            ? subviews[SubviewIndex.controls.rawValue]
            : subviews[SubviewIndex.topBar.rawValue]

        place(
            leadingSubview,
            in: CGRect(
                x: bounds.minX,
                y: bounds.minY,
                width: railWidth,
                height: bounds.height
            )
        )
        place(
            subviews[SubviewIndex.preview.rawValue],
            in: CGRect(
                x: bounds.minX + railWidth,
                y: bounds.minY,
                width: max(.zero, bounds.width - (railWidth * 2)),
                height: bounds.height
            )
        )
        place(
            trailingSubview,
            in: CGRect(
                x: bounds.maxX - railWidth,
                y: bounds.minY,
                width: railWidth,
                height: bounds.height
            )
        )
    }

    private func place(_ subview: LayoutSubview, in frame: CGRect) {
        subview.place(
            at: frame.origin,
            anchor: .topLeading,
            proposal: ProposedViewSize(frame.size)
        )
    }

}

enum CameraPreviewOrientation: Equatable {

    case portrait
    case landscapeLeft
    case landscapeRight

    init(size: CGSize, landscapeSide: CameraLandscapeSide) {
        guard size.width > size.height else {
            self = .portrait
            return
        }

        self = landscapeSide == .left ? .landscapeLeft : .landscapeRight
    }

    var controlsLayout: CameraPreviewControls.Layout {
        self == .portrait ? .horizontal : .vertical
    }

    var controlRotationDegrees: Double {
        switch self {
        case .portrait:
            .zero
        case .landscapeLeft:
            90
        case .landscapeRight:
            -90
        }
    }

    var topBarPlacement: CameraPreviewTopBar.Placement {
        self == .portrait ? .top : .side
    }

    var topBarOnLeadingEdge: Bool {
        self == .landscapeLeft
    }

}

enum CameraLandscapeSide: Equatable {

    case left
    case right

}

private enum SubviewIndex: Int, CaseIterable {
    case topBar
    case preview
    case controls
}
#endif
