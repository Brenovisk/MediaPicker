//
//  CaptureSessionEventObserver.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

import AVFoundation
import Foundation

/** Maps AVFoundation notifications to Domain camera events. */
final class CaptureSessionEventObserver: @unchecked Sendable {

    private let center: NotificationCenter
    private let lock = NSLock()
    private var tokens: [NSObjectProtocol] = []

    init(center: NotificationCenter = .default) {
        self.center = center
    }

    deinit {
        stop()
    }

    // MARK: Observation Lifecycle

    func start(
        session: AVCaptureSession,
        handler: @escaping @Sendable (CameraSessionEvent) -> Void
    ) {
        lock.withLock {
            guard tokens.isEmpty else { return }

            tokens = [
                observe(
                    AVCaptureSession.wasInterruptedNotification,
                    session: session,
                    handler: handler
                ),
                observe(
                    AVCaptureSession.interruptionEndedNotification,
                    session: session,
                    handler: handler
                ),
                observe(
                    AVCaptureSession.runtimeErrorNotification,
                    session: session,
                    handler: handler
                )
            ]
        }
    }

    func stop() {
        let currentTokens = lock.withLock {
            let currentTokens = tokens
            tokens.removeAll()
            return currentTokens
        }

        currentTokens.forEach(center.removeObserver)
    }

    private func observe(
        _ notification: Notification.Name,
        session: AVCaptureSession,
        handler: @escaping @Sendable (CameraSessionEvent) -> Void
    ) -> NSObjectProtocol {
        center.addObserver(forName: notification, object: session, queue: nil) {
            handler(Self.event(from: $0))
        }
    }

    // MARK: Event Mapping

    private static func event(from notification: Notification) -> CameraSessionEvent {
        switch notification.name {
        case AVCaptureSession.interruptionEndedNotification:
            return .interruptionEnded
        case AVCaptureSession.runtimeErrorNotification:
            return runtimeEvent(from: notification)
        default:
            return .interruptionBegan(interruptionReason(from: notification))
        }
    }

    private static func runtimeEvent(from notification: Notification) -> CameraSessionEvent {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError,
              let code = AVError.Code(rawValue: error.code) else {
            return .runtimeFailure(.captureSessionRuntimeFailed)
        }

    #if os(iOS) && !targetEnvironment(macCatalyst)
        if code == .mediaServicesWereReset {
            return .mediaServicesWereReset
        }
    #endif

        switch code {
        case .deviceInUseByAnotherApplication:
            return .runtimeFailure(.cameraInUse)
        case .deviceWasDisconnected:
            return .runtimeFailure(.cameraUnavailable)
        default:
            return .runtimeFailure(.captureSessionRuntimeFailed)
        }
    }

    private static func interruptionReason(
        from notification: Notification
    ) -> CameraSessionEvent.InterruptionReason {
    #if os(iOS) && !targetEnvironment(macCatalyst)
        guard let value = notification.userInfo?[AVCaptureSessionInterruptionReasonKey]
            as? NSNumber,
              let reason = AVCaptureSession.InterruptionReason(rawValue: value.intValue)
        else { return .unknown }

        switch reason {
        case .audioDeviceInUseByAnotherClient, .videoDeviceInUseByAnotherClient:
            return .cameraInUse
        case .videoDeviceNotAvailableWithMultipleForegroundApps:
            return .multipleForegroundApps
        case .videoDeviceNotAvailableDueToSystemPressure:
            return .systemPressure
        case .videoDeviceNotAvailableInBackground,
             .sensitiveContentMitigationActivated:
            return .unavailable
        @unknown default:
            return .unknown
        }
    #else
        return .unknown
    #endif
    }

}
