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
    
    @State var amountPlayed: Double = 0.0 // in range 0...1
    @State var playing: Bool = false

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
            
            // Look up systemImage icons (which are just a font) with SF Symbols https://developer.apple.com/sf-symbols/
            // There might already be color inverted versions of these symbols.
            
            // We could also completely hide these controls in the menu and accept only hotkeys
            HStack() {
                Image(systemName: "backward.end.fill").padding(5).border(Color.black).onTapGesture {
                    print("PREV")
                    if let p = player, p.isPlaying, p.currentTime < 2 {
                        jumpToTrack(state.currentTrack)
                    } else {
                        jumpToTrack(state.currentTrack - 1);
                    }
                }
                // Comment on Button("Label", action: {}) {Image()} as opposed to Image().onTapGesture()
                // Button has a lot more chrome around it, moves when clicked, and looks more cluttered.
                Button(action: {
                        print("PLAY")
                        if let p = player {
                            if !p.isPlaying {
                                p.play()
                                state.playing = true;
                            }
                        } else {
                            jumpToTrack(state.currentTrack);
                        }
                }) { Image(systemName: "play.fill") }
                .padding(5)
                .background(playing ? Color.gray : Color.white)
                .buttonStyle(BorderlessButtonStyle())
                
                Image(systemName: "pause.fill").padding(5).border(Color.black).onTapGesture {
                    print("PAUSE")
                    player?.pause()
                    state.playing = false
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
            Slider(
                value: Binding(
                    get: {
                        let duration = player?.duration ?? 0;
                        if (duration == 0) {
                            return 0;
                        } else {
                            return (player?.currentTime ?? 0) / duration
                        }
                    },
                    set: {
                        newValue in player?.play(atTime: player!.duration * newValue)
                    }
                ),
                in: 0...1
            )
        }
    }

    // TODO implement auto-next-track (with crossfade using setVolume(t) ?)
    
    // /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -dump | grep flac
    // Shows UTI org.xiph.flac
    
    private func jumpToTrack (_ trackNumber: Int) {
        if (trackNumber >= 0 && trackNumber < state.playlist.count) {
            // Cleanly stop any existing player. It will be garbage collected when we dereference it.
            player?.stop()
            do {
                player = try AVAudioPlayer(contentsOf: state.playlist[trackNumber], fileTypeHint: "org.xiph.flac")
                guard let player = player else { return }
                player.play()
                state.currentTrack = trackNumber;
                playing = true
            } catch let error {
                print(error.localizedDescription)
            }
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

