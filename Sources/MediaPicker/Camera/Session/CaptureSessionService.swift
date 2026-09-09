import Dispatch

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
    private var configuredPosition: CameraPosition?

    nonisolated var unownedExecutor: UnownedSerialExecutor {
        executor.asUnownedSerialExecutor()
    }

    init(operations: CaptureSessionOperations = .live) {
        executor = DispatchSerialQueue(
            label: MediaPickerInfrastructureConstants.captureSessionQueueLabel
        )
        self.operations = operations
    }

    func configure(for position: CameraPosition) throws {
        guard configuredPosition != position else { return }

        guard configuredPosition == nil else {
            throw MediaPickerError.captureSessionConfigurationFailed
        }

        do {
            try operations.configure(position)
            configuredPosition = position
        } catch let error as MediaPickerError {
            throw error
        } catch {
            throw MediaPickerError.captureSessionConfigurationFailed
        }
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
