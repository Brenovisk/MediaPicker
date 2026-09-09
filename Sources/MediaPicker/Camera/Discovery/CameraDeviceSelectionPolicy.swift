/**
 Selects camera devices using a stable priority instead of relying on discovery order.

 Back cameras prefer versatile multi-camera devices before individual lenses:
 triple, dual-wide, dual, wide-angle, ultra-wide, telephoto, then external.
 Front cameras prefer TrueDepth, followed by wide-angle and external cameras.
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
            [.triple, .dualWide, .dual, .wideAngle, .ultraWide, .telephoto, .external, .unknown]
        case .front:
            [.trueDepth, .wideAngle, .external, .unknown]
        }
    }

}
