//
//  ColdwaveApp.swift
//  Coldwave
//
//  Created by Andrew Byrd on 05/07/2021.
//

import SwiftUI
import AVFoundation

var timer: Timer?
var player: AVAudioPlayer?

@main
struct ColdwaveApp: App {
    
    @StateObject var state: ColdwaveState = ColdwaveState()
    
    var body: some Scene {
        WindowGroup {
            ContentView(state: state).onAppear() {
                // Setup here
            }
        }
        .commands {
            CommandGroup(before: CommandGroupPlacement.newItem) {
                Button(action: { openFolder() }, label: { Label("Open directory...", systemImage: "doc") })
                    .keyboardShortcut("o")
            }
            CommandMenu("Utilities") {
                Button("Bigger") {
                    if (state.coverSize < MAX_IMAGE_SIZE) { state.coverSize += IMAGE_SIZE_STEP }
                }.keyboardShortcut("+")
                Button("Smaller") {
                    if (state.coverSize > MIN_IMAGE_SIZE) { state.coverSize -= IMAGE_SIZE_STEP }
                }.keyboardShortcut("-")
            }
        }
    }
    
    private func openFolder () {
        let dialog = NSOpenPanel();
        dialog.title                   = "Choose root music directory | ABCD";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.allowsMultipleSelection = false;
        dialog.canChooseDirectories    = true;
        dialog.canChooseFiles          = false;
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url
            if (result != nil) {
                state.path = result!.path;
                // Change this, it should happen automatically on state update
                state.albums = Album.scanLibrary(at: state.path)
            }
        }
    }
    
    private class OrigamiDelegate: NSObject {
        private var parent: ColdwaveApp
        init (_ parent: ColdwaveApp) {
            self.parent = parent
        }
        func engineExpectsNextUrl() -> URL! {
            var nextTrack = parent.state.currentTrack + 1
            if (nextTrack >= parent.state.playlist.count) {
                nextTrack = 0
            }
            // This is publishing from a background thread... fix it.
            let nextUrl = parent.state.playlist[nextTrack]
            print("Auto-advancing to next track: " + nextUrl.lastPathComponent)
            parent.state.currentTrack = nextTrack
            return nextUrl
        }
    }
}

class ColdwaveState: ObservableObject {
    @Published var albums: [Album] = []
    @Published var path: String = "";
    @Published var currentTrack = 0
    @Published var coverSize: CGFloat = DEFAULT_IMAGE_SIZE
    @Published var playlist: [URL]  = []
}

