//
//  ContentView.swift
//  Heatwave
//
//  Created by Andrew Byrd on 21/03/2021.
//

import SwiftUI

let MIN_IMAGE_SIZE: CGFloat = 100
let MAX_IMAGE_SIZE: CGFloat = 800
let IMAGE_SIZE_STEP: CGFloat = 50
let DEFAULT_IMAGE_SIZE: CGFloat = 400

struct ContentView: View {
    
    @ObservedObject var state: ColdwaveState
    
    @State var amountPlayed: Double = 0.5

    private let padding: CGFloat = 20
    
    var body: some View {
        VStack {
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
                            Image(nsImage: NSImage(contentsOfFile: album.coverImagePath) ??
                                    NSImage(named: "record-sleeve-\(abs(album.title.hashValue % 2)).png")!)
                                .resizable()
                                .frame(width: state.coverSize, height: state.coverSize, alignment: .center)
                                //.border(Color.black)
                                .shadow(radius: 4)
                            // Ideally name would be vertically oriented beside album cover, like spine text, but
                            // using HStack with Text().rotationEffect(Angle(degrees: -90)) causes misalignment
                            Text(album.artist)
                            Text(album.title)
                        }
                        .onTapGesture {
                            state.playlist = album.getPlaylist() as [URL]
                            jumpToTrack(0);
                        }
                    }
                }.padding(padding)
            }
            //.onAppear() {
            //}
            // We could also completely hide these controls in the menu and accept only hotkeys
            HStack() {
                Image(systemName: "backward.end.fill").padding(5).border(Color.black).onTapGesture {
                    print("PREV")
                    jumpToTrack(state.currentTrack - 1);
                }
                Image(systemName: "play.fill").padding(5).border(Color.black).onTapGesture {
                    print("PLAY")
                    origami.resume()
                }
                Image(systemName: "pause.fill").padding(5).border(Color.black).onTapGesture {
                    print("PAUSE")
                    origami.pause()
                }
                Image(systemName: "forward.end.fill").padding(5).border(Color.black).onTapGesture {
                    print("NEXT")
                    jumpToTrack(state.currentTrack + 1);
                }
                let selectedItem = (state.playlist.isEmpty) ? "Album Tracks" : state.playlist[state.currentTrack].lastPathComponent
                Menu(selectedItem) {
                    ForEach(state.playlist.indices, id: \.self) { trackIndex in
                        Button(state.playlist[trackIndex].lastPathComponent) {
                            jumpToTrack(trackIndex)
                        }.id(trackIndex)
                    }
                }
            }.padding(5)
            // Slider(value: $amountPlayed, in: 0...1)
            // get: {origami.amountPlayed() / origami.trackTime()},
            // set: {newValue in origami.seek(toTime: origami.trackTime() * newValue)}
        }
    }
    
    private func jumpToTrack (_ trackNumber: Int) {
        if (trackNumber >= 0 && trackNumber < state.playlist.count) {
            origami.play(state.playlist[trackNumber])
            state.currentTrack = trackNumber;
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(state: ColdwaveState())
        }
    }
}

