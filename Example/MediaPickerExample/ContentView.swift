//
//  ContentView.swift
//  MediaPicker-Example
//
//  Created by Breno Souza on 24/08/26.
//

import MediaPicker
import SwiftUI

struct ContentView: View {

    @State private var cameraAccessMessage = "Camera access has not been checked."
    @State private var showsCameraPreview = false

    var body: some View {
        Group {
            if showsCameraPreview {
                CameraPreview(
                    onCapture: handleCapturedPhoto,
                    onCancel: returnToStart
                )
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "camera")
                        .imageScale(.large)
                        .foregroundStyle(.tint)

                    Text(cameraAccessMessage)
                        .multilineTextAlignment(.center)

                    Button("Open camera") {
                        Task { @MainActor in
                            await prepareCameraAccess()
                        }
                    }
                }
                .padding()
            }
        }
    }

}

// MARK: Helper Methods
extension ContentView {

    @MainActor
    private func prepareCameraAccess() async {
        do {
            try await MediaPicker().prepareCameraAccess()
            cameraAccessMessage = "Camera access is authorized."
            showsCameraPreview = true
        } catch let error as MediaPickerError {
            cameraAccessMessage = error.localizedDescription
        } catch {
            cameraAccessMessage = "Camera access could not be determined."
        }
    }

    private func returnToStart() {
        showsCameraPreview = false
    }

    private func handleCapturedPhoto(_: CapturedMedia) {
        showsCameraPreview = false
    }

}

#Preview {
    ContentView()
}
