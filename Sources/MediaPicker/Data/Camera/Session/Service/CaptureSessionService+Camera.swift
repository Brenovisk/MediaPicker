//
//  CaptureSessionService+Camera.swift
//  MediaPicker
//
//  Created by Breno Lucas on 11/09/26.
//

/** Handles camera configuration, switching, lighting and capture capabilities. */
extension CaptureSessionService {

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

    @discardableResult
    func switchCamera() throws -> CameraPosition {
        guard canSwitchCamera, let configuredPosition else {
            throw MediaPickerError.captureSessionSwitchFailed
        }

        let newPosition = configuredPosition.opposite

        do {
            try operations.switchCamera(newPosition)
            self.configuredPosition = newPosition
            refreshCameraCapabilities()
            return newPosition
        } catch let error as MediaPickerError {
            throw error
        } catch {
            throw MediaPickerError.captureSessionSwitchFailed
        }
    }

    func setFlashMode(_ mode: CameraFlashMode) throws {
        guard lightingCapabilities.flashModes.contains(mode) else {
            throw MediaPickerError.unsupportedFlashMode
        }
        flashMode = mode
    }

    func setTorchMode(_ mode: CameraTorchMode) throws {
        guard lightingCapabilities.torchModes.contains(mode) else {
            throw MediaPickerError.unsupportedTorchMode
        }

        do {
            try operations.setTorchMode(mode)
            torchMode = mode
        } catch {
            throw MediaPickerError.cameraDeviceConfigurationFailed
        }
    }

    func refreshCameraCapabilities() {
        lightingCapabilities = operations.lightingCapabilities()
        photoOutputCapabilities = operations.photoOutputCapabilities()

        if lightingCapabilities.flashModes.contains(flashMode) == false {
            flashMode = .off
        }

        if lightingCapabilities.torchModes.contains(torchMode) == false {
            torchMode = .off
        }
    }

    func resetSession() {
        operations.reset()
        configuredPosition = nil
        lightingCapabilities = .unavailable
        photoOutputCapabilities = .unavailable
        flashMode = .off
        torchMode = .off
    }

}
