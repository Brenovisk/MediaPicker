//
//  CameraSessionControlling.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

/**
 Defines the camera-session operations available to Domain use cases.

 Use cases depend on this protocol instead of `CaptureSessionService`, keeping
 session implementation details and AVFoundation out of the ViewModel. The live
 implementation is `CaptureSessionService`; tests may provide lightweight spies.

 Implementations must serialize mutable session operations, preserve consistent
 state and camera position, and translate framework failures into domain errors.
 The contract is `Sendable` because calls cross actor boundaries under Swift 6.
*/
protocol CameraSessionControlling: Sendable {

    var state: CameraState { get async }
    var activeCameraPosition: CameraPosition? { get async }

    var lightingCapabilities: CameraLightingCapabilities { get async }
    var flashMode: CameraFlashMode { get async }
    var torchMode: CameraTorchMode { get async }

    func open(for position: CameraPosition) async throws
    func close() async throws

    func applicationDidEnterBackground() async throws
    func applicationWillEnterForeground() async throws

    func switchCamera() async throws -> CameraPosition
    func capturePhoto(format: PhotoOutputFormat) async throws -> CapturedMedia

    func setFlashMode(_ mode: CameraFlashMode) async throws
    func setTorchMode(_ mode: CameraTorchMode) async throws
    func updates() async -> AsyncStream<CameraSessionSnapshot>

}

extension CameraSessionControlling {

    func snapshot() async -> CameraSessionSnapshot {
        await CameraSessionSnapshot(
            state: state,
            position: activeCameraPosition,
            lightingCapabilities: lightingCapabilities,
            flashMode: flashMode,
            torchMode: torchMode
        )
    }

}
