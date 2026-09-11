/**
 Selects camera devices using a stable priority instead of relying on discovery order.

 Both positions prefer the physical wide-angle camera because it activates more
 quickly when replacing an input. Virtual multi-camera and TrueDepth devices
 remain predictable fallbacks when a wide-angle device is unavailable.
 Unknown device types remain usable as the final fallback for either position.
*/
struct CameraDeviceSelectionPolicy {

    func bestDevice<Device: CameraDeviceCandidate>(
        for position: CameraPosition,
        among devices: [Device]
    ) throws -> Device {
        let matchingDevices = devices.filter { $0.cameraPosition == position }

        for kind in priority(for: position) {
            if let device = matchingDevices.first(where: { $0.cameraDeviceKind == kind }) {
                return device
            }
        }

        throw MediaPickerError.sourceUnavailable(.camera)
    }

    private func priority(for position: CameraPosition) -> [CameraDeviceKind] {
        switch position {
        case .back:
            [.wideAngle, .triple, .dualWide, .dual, .ultraWide, .telephoto, .external, .unknown]
        case .front:
            [.wideAngle, .trueDepth, .external, .unknown]
        }
    }

}
