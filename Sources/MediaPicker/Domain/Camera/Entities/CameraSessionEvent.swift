//
//  CameraSessionEvent.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

/** Events emitted asynchronously by the underlying capture session. */
enum CameraSessionEvent: Sendable, Equatable {

    enum InterruptionReason: Sendable, Equatable {
        case cameraInUse
        case multipleForegroundApps
        case systemPressure
        case unavailable
        case unknown

        var requiresUserAction: Bool {
            switch self {
            case .cameraInUse, .multipleForegroundApps:
                return true
            case .systemPressure, .unavailable, .unknown:
                return false
            }
        }
    }

    case interruptionBegan(InterruptionReason)
    case interruptionEnded
    case mediaServicesWereReset
    case runtimeFailure(MediaPickerError)

}
