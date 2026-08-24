import Testing
@testable import MediaPicker

struct MediaPickerTests {
    @Test func mediaPickerReturnsGreeting() {
        let mediaPicker = MediaPicker()

        #expect(mediaPicker.hello() == "Olá do meu SPM Framework!")
    }
}
