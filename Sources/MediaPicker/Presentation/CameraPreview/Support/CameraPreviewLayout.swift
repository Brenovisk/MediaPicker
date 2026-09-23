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
    let showsTopBar: Bool
    let showsMediaSelector: Bool

    init(
        orientation: CameraPreviewOrientation,
        showsTopBar: Bool = true,
        showsMediaSelector: Bool = true
    ) {
        self.orientation = orientation
        self.showsTopBar = showsTopBar
        self.showsMediaSelector = showsMediaSelector
    }

    var reservedTopBarHeight: CGFloat {
        showsTopBar ? CameraPreviewConstants.Layout.portraitTopBarHeight : .zero
    }

    var reservedTopBarWidth: CGFloat {
        showsTopBar ? CameraPreviewConstants.Layout.topBarRailWidth : .zero
    }

    var reservedControlsHeight: CGFloat {
        showsMediaSelector
            ? CameraPreviewConstants.Layout.portraitControlsHeightWithSelector
            : CameraPreviewConstants.Layout.portraitControlsHeightWithoutSelector
    }

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

        let frames = frames(in: bounds)
        place(subviews[SubviewIndex.topBar.rawValue], in: frames.topBar)
        place(subviews[SubviewIndex.preview.rawValue], in: frames.preview)
        place(subviews[SubviewIndex.controls.rawValue], in: frames.controls)
    }

    func frames(in bounds: CGRect) -> CameraPreviewLayoutFrames {
        guard bounds.width > .zero, bounds.height > .zero else {
            let parked = parkedFrame(outside: bounds)
            return CameraPreviewLayoutFrames(
                topBar: parked,
                preview: parked,
                controls: parked
            )
        }

        switch orientation {
        case .portrait:
            return portraitFrames(in: bounds)
        case .landscapeLeft, .landscapeRight:
            return landscapeFrames(in: bounds)
        }
    }

    private func portraitFrames(in bounds: CGRect) -> CameraPreviewLayoutFrames {
        let lengths = fittedLengths(
            first: reservedTopBarHeight,
            second: reservedControlsHeight,
            total: bounds.height
        )
        let topBar = showsTopBar
            ? CGRect(
                x: bounds.minX,
                y: bounds.minY,
                width: bounds.width,
                height: lengths.first
            )
            : parkedFrame(outside: bounds)

        return CameraPreviewLayoutFrames(
            topBar: topBar,
            preview: CGRect(
                x: bounds.minX,
                y: bounds.minY + lengths.first,
                width: bounds.width,
                height: lengths.content
            ),
            controls: CGRect(
                x: bounds.minX,
                y: bounds.maxY - lengths.second,
                width: bounds.width,
                height: lengths.second
            )
        )
    }

    private func landscapeFrames(in bounds: CGRect) -> CameraPreviewLayoutFrames {
        let lengths = fittedLengths(
            first: reservedTopBarWidth,
            second: CameraPreviewConstants.Layout.landscapeControlsWidth,
            total: bounds.width
        )
        let topBar = showsTopBar
            ? CGRect(
                x: bounds.minX,
                y: bounds.minY,
                width: lengths.first,
                height: bounds.height
            )
            : parkedFrame(outside: bounds)

        return CameraPreviewLayoutFrames(
            topBar: topBar,
            preview: CGRect(
                x: bounds.minX + lengths.first,
                y: bounds.minY,
                width: lengths.content,
                height: bounds.height
            ),
            controls: CGRect(
                x: bounds.maxX - lengths.second,
                y: bounds.minY,
                width: lengths.second,
                height: bounds.height
            )
        )
    }

    private func fittedLengths(
        first: CGFloat,
        second: CGFloat,
        total: CGFloat
    ) -> FittedLayoutLengths {
        let minimumContent = min(1, total)
        let available = max(.zero, total - minimumContent)
        let requested = first + second
        let scale = requested > available && requested > .zero
            ? available / requested
            : 1
        let fittedFirst = first * scale
        let fittedSecond = second * scale
        return FittedLayoutLengths(
            first: fittedFirst,
            content: max(minimumContent, total - fittedFirst - fittedSecond),
            second: fittedSecond
        )
    }

    private func parkedFrame(outside bounds: CGRect) -> CGRect {
        CGRect(x: bounds.maxX + 1, y: bounds.maxY + 1, width: 1, height: 1)
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

    func valueTo<T>(portrait: T, landscapeLeft: T, landscapeRight: T) -> T {
        switch self {
        case .landscapeLeft:
            return landscapeLeft
        case .landscapeRight:
            return landscapeRight
        case .portrait:
            return portrait
        }
    }

    func valueTo<T>(portrait: T, landscape: T) -> T {
        switch self {
        case .landscapeLeft, .landscapeRight:
            return landscape
        case .portrait:
            return portrait
        }
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

struct CameraPreviewLayoutFrames: Equatable {

    let topBar: CGRect
    let preview: CGRect
    let controls: CGRect

}

private struct FittedLayoutLengths {

    let first: CGFloat
    let content: CGFloat
    let second: CGFloat

}
#endif
