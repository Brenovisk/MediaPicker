import AVFoundation
import Dispatch

/** Injectable session commands used to test the actor without real hardware. */
struct CaptureSessionOperations: Sendable {

    let startRunning: @Sendable () throws -> Void
    let stopRunning: @Sendable () throws -> Void

    static var live: CaptureSessionOperations {
        let storage = CaptureSessionStorage()

        return CaptureSessionOperations(
            startRunning: storage.startRunning,
            stopRunning: storage.stopRunning
        )
    }

}

/**
 The only type that owns and directly mutates `AVCaptureSession`.

 This type is private to this file, and its operations are executed exclusively
 by `CaptureSessionService` on the dedicated serial executor.
*/
private final class CaptureSessionStorage: @unchecked Sendable {

    private let session = AVCaptureSession()

    func startRunning() {
        session.startRunning()
    }

    func stopRunning() {
        session.stopRunning()
    }

}

/**
 Serializes all mutable capture-session work away from the main thread.

 The service owns a dedicated serial executor. Calls may originate from UI code,
 but session operations always execute on this actor. Presentation code receives
 only asynchronous commands and never accesses `AVCaptureSession` directly.

 Future input, output, and configuration mutations must be implemented as actor
 methods here to preserve this isolation.
*/
actor CaptureSessionService {

    nonisolated private let executor: DispatchSerialQueue
    private let operations: CaptureSessionOperations

    nonisolated var unownedExecutor: UnownedSerialExecutor {
        executor.asUnownedSerialExecutor()
    }

    init(operations: CaptureSessionOperations = .live) {
        executor = DispatchSerialQueue(
            label: MediaPickerInfrastructureConstants.captureSessionQueueLabel
        )
        self.operations = operations
    }

    func startRunning() throws {
        do {
            try operations.startRunning()
        } catch {
            throw MediaPickerError.captureSessionStartFailed
        }
    }

    func stopRunning() throws {
        do {
            try operations.stopRunning()
        } catch {
            throw MediaPickerError.captureSessionStopFailed
        }
    }

}
