//
//  PlaybackControlView.swift
//  Coldwave
//
//  Created by Andrew Byrd on 3/10/2021.
//

import SwiftUI
import Foundation
import AVFoundation

struct PlaybackControlView: View {
    
    @ObservedObject var state: ColdwaveState

    var body: some View {
        // Horizonal row of controls at the bottom of the window.
        // We could also completely hide these controls in the menu and accept only hotkeys.
        // Use Image views with tap gesture listeners - they are simpler with less chrome than buttons.
        // Tappable area of the images seems not to include the padding inside the border though.
        HStack() {
            Image(systemName: "backward.end.fill").padding(5).border(Color.black).onTapGesture {
                state.jumpToTrack(state.currentTrack - 1)
            }
            Image(systemName: "play.fill").padding(5).border(Color.black, width: state.playing ? 3 : 1).onTapGesture {
                state.play()
            }
            Image(systemName: "pause.fill").padding(5).border(Color.black, width: state.playing ? 1 : 3).onTapGesture {
                state.pause()
            }
            Image(systemName: "forward.end.fill").padding(5).border(Color.black).onTapGesture {
                state.jumpToTrack(state.currentTrack + 1);
            }
            let selectedItem = (state.playlist.isEmpty) ? "Album Tracks"
                : state.playlist[state.currentTrack].lastPathComponent
            Menu(selectedItem) {
                ForEach(state.playlist.indices, id: \.self) { trackIndex in
                    Button(state.playlist[trackIndex].lastPathComponent) {
                        state.jumpToTrack(trackIndex)
                    }.id(trackIndex)
                }
            }
        }.padding(PADDING).focusable(false)
        // When slider is moved, trailing closure is called with true, then false when released.
        // Dragging is quite unresponsive, maybe because the UI is recomputed when state changes.
        Slider(value: $state.amountPlayed, in: 0...1) {editing in
            if (!editing) {
                if let d = state.player.currentItem?.duration {
                    let newPosition = (Double(d.value) * state.amountPlayed)
                    state.player.seek(to: CMTimeMake(value: Int64(newPosition), timescale: d.timescale))
                }
            }
        }.padding(PADDING).focusable(false)
        // Text(String(state.amountPlayed))
    }
    
    private func mmss (seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds - minutes * 60
        return String(format: "%3i:%02i", minutes, seconds)
    }
    
}
