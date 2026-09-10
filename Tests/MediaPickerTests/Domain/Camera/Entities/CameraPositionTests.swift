import MediaPicker
import Testing

struct CameraPositionTests {

    @Test func frontAndBackAreDistinctPositions() {
        #expect(CameraPosition.front != .back)
    }

    @Test func cameraPositionIsSendable() {
        requireSendable(CameraPosition.back)
    }

}

// MARK: Helper Methods
extension CameraPositionTests {

    private func requireSendable<T: Sendable>(_: T) {}

}
