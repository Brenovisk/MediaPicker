//
//  CameraSwitcherSpy.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

#if os(iOS)
@testable import MediaPicker
import Testing

actor CameraSwitcherSpy: CameraSessionControlling {

    private var positions: [CameraPosition]
    private(set) var switchCount = 0

    var state: CameraState { .ready }
    var activeCameraPosition: CameraPosition? { positions.first }

    init(positions: [CameraPosition]) {
        self.positions = positions
    }

    func switchCamera() throws -> CameraPosition {
        switchCount += 1
        return positions.removeFirst()
    }

    func open(for position: CameraPosition) throws {}
    func close() throws {}
    func applicationDidEnterBackground() throws {}
    func applicationWillEnterForeground() throws {}

}

#endif
