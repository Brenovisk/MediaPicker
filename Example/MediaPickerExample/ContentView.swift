//
//  ContentView.swift
//  MediaPicker-Example
//
//  Created by Breno Souza on 24/08/26.
//

import MediaPicker
import SwiftUI

struct ContentView: View {

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(MediaPicker().hello())
        }
        .padding()
    }

}

#Preview {
    ContentView()
}
