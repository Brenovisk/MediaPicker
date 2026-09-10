//
//  CameraPreview.swift
//  MediaPicker
//
//  Created by Breno Lucas on 09/09/26.
//

#if os(iOS)
import SwiftUI

/** Displays the live camera feed without exposing AVFoundation session types. */
public struct CameraPreview: View {

    @Environment(\.scenePhase) private var scenePhase
    @State private var service: CaptureSessionService
    private let position: CameraPosition

    public init(position: CameraPosition = .back) {
        self.position = position
        _service = State(initialValue: CaptureSessionService())
    }

    public var body: some View {
        Group {
            if let previewSession = service.previewSession {
                CameraPreviewRepresentable(previewSession: previewSession)
            }
        }
        .task {
            try? await service.open(for: position)
        }
        .onDisappear {
            Task {
                try? await service.close()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            updateSession(for: phase)
        }
    }

    private func updateSession(for phase: ScenePhase) {
        Task {
            switch phase {
            case .active:
                try? await service.applicationWillEnterForeground()
            case .background:
                try? await service.applicationDidEnterBackground()
            case .inactive:
                break
            @unknown default:
                break
            }
        }
    }

}
#endif
