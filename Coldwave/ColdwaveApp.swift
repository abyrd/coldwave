//
//  ColdwaveApp.swift
//  Coldwave
//
//  Created by Andrew Byrd on 05/07/2021.
//

import SwiftUI
import AVFoundation

@main
struct ColdwaveApp: App {
    
    @StateObject var state: ColdwaveState = ColdwaveState()
    
    var body: some Scene {
        WindowGroup {
            ContentView(state: state)
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

}


class ColdwaveState: ObservableObject {
    @Published var albums: [Album] = []
    @Published var path: String = "";
    @Published var currentAlbum: Album?
    @Published var currentTrack = 0
    @Published var coverSize: CGFloat = DEFAULT_IMAGE_SIZE
    @Published var playlist: [URL]  = []
    @Published var amountPlayed: Double = 0.0 // in range 0...1
    @Published var playing: Bool = false

    let player: AVPlayer = AVPlayer()

    init() {
        player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
            queue: .main
        ) { t in
            // Compare two CMTimeScales and update slider via state.
            // Assuming duration and current time are in same units for now
            if let duration = self.player.currentItem?.duration.convertScale(t.timescale, method: CMTimeRoundingMethod.default) {
                self.amountPlayed = Double(t.value) / Double(duration.value)
            }
        }
    }
    
    // It doesn't seem clean to put this (or the AVPlayer) on the state, but notification
    // targets have to be objc functions which have to be members of an NSObject or protocol.
    // I could probably factor the player field and these methods out into another class.
    // But then how would they set state?
    @objc func playerDidFinishPlaying(sender: Notification) {
        print("End of track \(currentTrack), advancing.")
        jumpToTrack(currentTrack + 1)
    }

    func jumpToTrack (album: Album, trackNumber: Int) {
        currentAlbum = album;
        playlist = album.getPlaylist()
        jumpToTrack(trackNumber)
    }

    // TODO implement next-track crossfade using setVolume(t)? That's only available on AVAudioPlayer.
    func jumpToTrack (_ trackNumber: Int) {
        if (trackNumber >= 0 && trackNumber < playlist.count) {
            let track = AVPlayerItem(asset: AVAsset(url: playlist[trackNumber]))
            player.replaceCurrentItem(with: track)
            player.play()
            currentTrack = trackNumber;
            playing = true
            // Deregister any previously registered end-of-track notifications
            NotificationCenter.default.removeObserver(self)
            NotificationCenter.default.addObserver(self,
                selector: #selector(playerDidFinishPlaying(sender:)),
                name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: track
            )
        } else {
            player.pause()
            playing = false
        }
    }

    func pause () {
        player.pause()
        playing = false
    }
    
    func play () {
        if (player.currentItem != nil) {
            player.play()
            playing = true
        }
    }

}

