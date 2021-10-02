//
//  ContentView.swift
//  Heatwave
//
//  Created by Andrew Byrd on 21/03/2021.
//

import SwiftUI
import AVFoundation

let MIN_IMAGE_SIZE: CGFloat = 100
let MAX_IMAGE_SIZE: CGFloat = 800
let IMAGE_SIZE_STEP: CGFloat = 50
let DEFAULT_IMAGE_SIZE: CGFloat = 400

struct ContentView: View {
    
    @ObservedObject var state: ColdwaveState
    @State var currentAlbum: Album? = nil
    @State var searchText: String = ""
    
    private let padding: CGFloat = 20
        
    var body: some View {
        VStack {
            // Text search box. This intentionally draws the keyboard focus away from the track selector
            // or time slider. They look less than great with a permanent fat blue focus ring.
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search", text: $searchText,
                    onCommit: {
                        print("onCommit")
                    }).foregroundColor(.primary)
                Image(systemName: "xmark.circle.fill").opacity(searchText == "" ? 0 : 1).onTapGesture {
                    searchText = ""
                }
            }
            .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
            .foregroundColor(.secondary)
            .cornerRadius(10.0)

            // Either a full-size album cover or a scrollable view of all album covers if no album is playing.
            if (state.playing) {
                Image(nsImage: currentAlbum!.coverAsNSImage())
                    .resizable()
                    //.frame(width: state.coverSize, height: state.coverSize, alignment: .center)
                    .border(Color.black)
                    .aspectRatio(contentMode: .fit)
                    .padding(padding)
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: state.coverSize))],
                        spacing: padding
                    ){
                        // ForEach with an initial capital F is a SwiftUI view, not the language construct.
                        // We should somehow hint to the renderer that the result of the ForEach view can only change
                        // when a new directory is opened. The approach of regenerating the view just to change the album
                        // size seems really inefficient, but maybe it is able to efficiently detect the situation.
                        // Maybe the ObservedObject should only contain the top level state, and all derived state should
                        // be in @state variables or normal variables.
                        ForEach(state.albums, id: \.self) { album in
                            VStack {
                                Image(nsImage: album.coverAsNSImage())
                                    .resizable()
                                    .frame(width: state.coverSize, height: state.coverSize, alignment: .center)
                                    .border(Color.black)
                                    .shadow(radius: 4)
                                // Ideally name would be vertically oriented beside album cover, like spine text, but
                                // using HStack with Text().rotationEffect(Angle(degrees: -90)) causes misalignment
                                Text(album.artist).bold()
                                Text(album.title).italic()
                            }
                            .onTapGesture(count: 2) {
                                currentAlbum = album;
                                state.playlist = album.getPlaylist()
                                state.jumpToTrack(0)
                            }
                        }
                    }.padding(padding)
                }
            }
            // Horizonal row of controls at the bottom of the window.
            // We could also completely hide these controls in the menu and accept only hotkeys.
            // Use Image views with tap gesture listeners - they are simpler with less chrome than buttons.
            HStack() {
                Image(systemName: "backward.end.fill").padding(5).border(Color.black).onTapGesture {
                    print("PREV")
                    state.jumpToTrack(state.currentTrack - 1)
                }
                Image(systemName: "play.fill").padding(5).border(Color.black, width: state.playing ? 3 : 1).onTapGesture {
                    print("PLAY")
                    if (state.player.currentItem != nil) {
                        state.player.play()
                        state.playing = true
                    }
                }
                Image(systemName: "pause.fill").padding(5).border(Color.black, width: state.playing ? 1 : 3).onTapGesture {
                    print("PAUSE")
                    state.player.pause()
                    state.playing = false
                }
                Image(systemName: "forward.end.fill").padding(5).border(Color.black).onTapGesture {
                    print("NEXT")
                    state.jumpToTrack(state.currentTrack + 1);
                }
                let selectedItem = (state.playlist.isEmpty)
                    ? "Album Tracks"
                    : state.playlist[state.currentTrack].lastPathComponent
                Menu(selectedItem) {
                    ForEach(state.playlist.indices, id: \.self) { trackIndex in
                        Button(state.playlist[trackIndex].lastPathComponent) {
                            state.jumpToTrack(trackIndex)
                        }.id(trackIndex)
                    }
                }.focusable(false)
            }.padding(padding)
            // When slider is moved, trailing closure is called with true, then false when released.
            // Dragging is quite unresponsive, maybe because the UI is recomputed when state changes.
            Slider(value: $state.amountPlayed, in: 0...1) {editing in
                if (!editing) {
                    if let d = state.player.currentItem?.duration {
                        let newPosition = (Double(d.value) * state.amountPlayed)
                        state.player.seek(to: CMTimeMake(value: Int64(newPosition), timescale: d.timescale))
                    }
                }
            }
            // Text(String(state.amountPlayed))
        }

    }
    
    private func mmss (seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds - minutes * 60
        return String(format: "%3i:%02i", minutes, seconds)
    }
    

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(state: ColdwaveState(), currentAlbum: nil)
        }
    }
}

