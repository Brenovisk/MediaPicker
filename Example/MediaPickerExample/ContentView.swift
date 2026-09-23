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
    @State private var selectedMediaTypes = ExampleMediaTypes.photo
    @State private var foregroundColor = Color.white
    @State private var backgroundColor = Color.black
    @State private var showsFlash = true
    @State private var showsSwitchCamera = true
    @State private var showsGallery = true
    @State private var showsReview = true

    var body: some View {
        Group {
            if showsCameraPreview {
                CameraPreview(
                    controlOptions: controlOptions,
                    onCapture: handleCapturedPhoto,
                    onCancel: returnToStart
                )
            } else {
                configurationForm
            }
        }
    }

    private var configurationForm: some View {
        NavigationStack {
            Form {
                Section("Camera") {
                    Label(cameraAccessMessage, systemImage: "camera")

                    Button("Open camera") {
                        Task { @MainActor in
                            await prepareCameraAccess()
                        }
                    }
                }

                Section("Control options") {
                    Picker("Media types", selection: $selectedMediaTypes) {
                        ForEach(ExampleMediaTypes.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }

                    Toggle("Flash", isOn: $showsFlash)
                    Toggle("Switch camera", isOn: $showsSwitchCamera)
                    Toggle("Gallery", isOn: $showsGallery)
                    Toggle("Review captured photo", isOn: $showsReview)
                }

                Section("Control colors") {
                    ColorPicker("Foreground", selection: $foregroundColor)
                    ColorPicker("Background", selection: $backgroundColor)
                }
            }
            .navigationTitle("MediaPicker")
        }
    }

    private var controlOptions: CameraPreviewControlOptions {
        CameraPreviewControlOptions(
            mediaTypes: selectedMediaTypes.value,
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            showsFlash: showsFlash,
            showsSwitchCamera: showsSwitchCamera,
            showsGallery: showsGallery,
            showsReview: showsReview
        )
    }

}

// MARK: Helper Methods
extension ContentView {

    @MainActor
    private func prepareCameraAccess() async {
        do {
            try await MediaPicker().prepareCameraAccess(for: .photo)
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

private enum ExampleMediaTypes: String, CaseIterable, Identifiable {

    case photo
    case photoAndVideo

    var id: Self { self }

    var title: String {
        switch self {
        case .photo:
            "Photo"
        case .photoAndVideo:
            "Photo and video"
        }
    }

    var value: MediaType {
        switch self {
        case .photo:
            .photo
        case .photoAndVideo:
            .photoAndVideo
        }
    }

}

#Preview {
    ContentView()
}
