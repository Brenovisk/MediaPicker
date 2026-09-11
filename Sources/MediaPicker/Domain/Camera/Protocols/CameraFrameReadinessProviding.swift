//
//  CameraFrameReadinessProviding.swift
//  MediaPicker
//
//  Created by Breno Lucas on 10/09/26.
//

#if os(iOS)
/**
 Abstracts how the camera flow determines whether a captured frame is ready.

 `SwitchCameraUseCase` depends on this contract instead of UIKit or
 `AVCaptureVideoPreviewLayer`. An adapter implements it by observing frame
 sequence numbers from the capture pipeline.

 A new implementation must return a monotonically increasing sequence and only
 report success from `waitForFrame(after:)` after a newer frame arrives. This
 prevents the frozen frame from being removed while the new camera still shows
 a black preview.

 The protocol runs on the Main Actor because its current adapter coordinates
 frame readiness with the UI transition. It remains class-only so adapters can
 preserve identity and keep weak UI links when necessary.
*/
@MainActor
protocol CameraFrameReadinessProviding: AnyObject {

    var latestFrameSequence: UInt64? { get }

    func waitForFrame(after sequence: UInt64?) async -> Bool

}
#endif
