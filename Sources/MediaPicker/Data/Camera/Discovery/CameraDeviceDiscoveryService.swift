import AVFoundation

/**
 Discovers the best available physical camera for a requested position.

 Discovery returning no devices is expected on environments such as the iOS
 Simulator. In that case the service reports `sourceUnavailable(.camera)` and
 never indexes an empty device collection.
*/
struct CameraDeviceDiscoveryService {

    private let selectionPolicy = CameraDeviceSelectionPolicy()

    func discoverDevice(for position: CameraPosition) throws -> AVCaptureDevice {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: Self.supportedDeviceTypes,
            mediaType: .video,
            position: position.captureDevicePosition
        )

        return try selectionPolicy.bestDevice(
            for: position,
            among: discoverySession.devices
        )
    }

    private static var supportedDeviceTypes: [AVCaptureDevice.DeviceType] {
        #if os(iOS)
        [
            .builtInTripleCamera,
            .builtInDualWideCamera,
            .builtInDualCamera,
            .builtInTrueDepthCamera,
            .builtInWideAngleCamera,
            .builtInUltraWideCamera,
            .builtInTelephotoCamera,
            .external
        ]
        #elseif os(macOS)
        [
            .builtInWideAngleCamera,
            .external
        ]
        #endif
    }

}

private extension CameraPosition {

    var captureDevicePosition: AVCaptureDevice.Position {
        #if os(macOS)
        return .unspecified
        #else
        switch self {
        case .back:
            .back
        case .front:
            .front
        }
        #endif
    }

}

extension AVCaptureDevice: CameraDeviceCandidate {

    var cameraPosition: CameraPosition {
        switch position {
        case .front:
            .front
        case .back:
            .back
        case .unspecified:
            #if os(macOS)
            .front
            #else
            .back
            #endif
        @unknown default:
            .back
        }
    }

    var cameraDeviceKind: CameraDeviceKind {
        #if os(iOS)
        switch deviceType {
        case .builtInTripleCamera:
            .triple
        case .builtInDualWideCamera:
            .dualWide
        case .builtInDualCamera:
            .dual
        case .builtInTrueDepthCamera:
            .trueDepth
        case .builtInWideAngleCamera:
            .wideAngle
        case .builtInUltraWideCamera:
            .ultraWide
        case .builtInTelephotoCamera:
            .telephoto
        case .external:
            .external
        default:
            .unknown
        }
        #elseif os(macOS)
        switch deviceType {
        case .builtInWideAngleCamera:
            .wideAngle
        case .external:
            .external
        default:
            .unknown
        }
        #endif
    }

    var cameraDeviceIdentifier: String {
        uniqueID
    }

}
