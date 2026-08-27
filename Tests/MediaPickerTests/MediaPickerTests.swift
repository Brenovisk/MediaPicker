@testable import MediaPicker
import Testing

struct MediaPickerTests {
    @Test func mediaPickerReturnsGreeting() {
        let mediaPicker = MediaPicker()

        #expect(mediaPicker.hello() == "Olá do meu SPM Framework!")
    }
}
