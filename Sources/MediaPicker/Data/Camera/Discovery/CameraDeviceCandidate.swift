/** The device information required by the camera-selection policy. */
protocol CameraDeviceCandidate {
    var cameraPosition: CameraPosition { get }
    var cameraDeviceKind: CameraDeviceKind { get }
    var cameraDeviceIdentifier: String { get }
}
