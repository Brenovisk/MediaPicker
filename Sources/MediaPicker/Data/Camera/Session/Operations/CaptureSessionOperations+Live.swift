//
//  CaptureSessionOperations+Live.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

/** Assembles the production AVFoundation dependencies used by the session actor. */
extension CaptureSessionOperations {

    static var live: CaptureSessionOperations {
        let previewSession = CaptureSessionReference()
        let eventObserver = CaptureSessionEventObserver()

        let storage = CaptureSessionStorage(
            session: previewSession.session,
            frameStore: previewSession.frameStore
        )

        return CaptureSessionOperations(
            previewSession: previewSession,
            configure: storage.configure,
            reset: storage.reset,
            startRunning: storage.startRunning,
            stopRunning: storage.stopRunning,
            prepareCameraSwitch: storage.prepareCameraSwitch,
            switchCamera: storage.switchCamera,
            lightingCapabilities: storage.lightingCapabilities,
            photoOutputCapabilities: storage.photoOutputCapabilities,
            capturePhoto: storage.capturePhoto,
            setTorchMode: storage.setTorchMode,
            startObservingEvents: { handler in
                eventObserver.start(session: previewSession.session, handler: handler)
            },
            stopObservingEvents: eventObserver.stop
        )
    }

}
