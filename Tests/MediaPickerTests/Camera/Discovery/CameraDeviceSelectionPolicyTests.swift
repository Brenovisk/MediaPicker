@testable import MediaPicker
import Testing

struct CameraDeviceSelectionPolicyTests {

    private let policy = CameraDeviceSelectionPolicy()

    @Test func bestBackCameraIsSelectedRegardlessOfDiscoveryOrder() throws {
        let devices = [
            CameraDeviceStub(identifier: "telephoto", position: .back, kind: .telephoto),
            CameraDeviceStub(identifier: "wide", position: .back, kind: .wideAngle),
            CameraDeviceStub(identifier: "triple", position: .back, kind: .triple)
        ]

        let device = try policy.bestDevice(for: .back, among: devices)

        #expect(device.cameraDeviceIdentifier == "triple")
    }

    @Test func frontCameraIsFoundWhenPresent() throws {
        let devices = [
            CameraDeviceStub(identifier: "back", position: .back, kind: .triple),
            CameraDeviceStub(identifier: "front-wide", position: .front, kind: .wideAngle),
            CameraDeviceStub(identifier: "true-depth", position: .front, kind: .trueDepth)
        ]

        let device = try policy.bestDevice(for: .front, among: devices)

        #expect(device.cameraDeviceIdentifier == "true-depth")
    }

    @Test func unavailablePreferredTypeFallsBackPredictably() throws {
        let devices = [
            CameraDeviceStub(identifier: "ultra-wide", position: .back, kind: .ultraWide),
            CameraDeviceStub(identifier: "wide", position: .back, kind: .wideAngle)
        ]

        let device = try policy.bestDevice(for: .back, among: devices)

        #expect(device.cameraDeviceIdentifier == "wide")
    }

    @Test func oppositePositionIsNeverUsedAsFallback() {
        let devices = [
            CameraDeviceStub(identifier: "back", position: .back, kind: .triple)
        ]

        #expect(throws: MediaPickerError.sourceUnavailable(.camera)) {
            try policy.bestDevice(for: .front, among: devices)
        }
    }

    @Test func emptyDiscoveryProducesCameraAvailabilityError() {
        let devices: [CameraDeviceStub] = []

        #expect(throws: MediaPickerError.sourceUnavailable(.camera)) {
            try policy.bestDevice(for: .back, among: devices)
        }
    }

}
