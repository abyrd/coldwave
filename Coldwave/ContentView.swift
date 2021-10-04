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
let GRID_SPACING: CGFloat = 20
let PADDING: CGFloat = 10

struct ContentView: View {
    
    @ObservedObject var state: ColdwaveState
    @State var searchText: String = ""
    
    var body: some View {
        VStack {
            // Top edge: text search box. This intentionally draws the keyboard focus away from the track selector
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
            
            // Center screen: Either a full-size album cover or a scrollable view of all covers if no album is playing.
            // This crudely sidesteps the AVPlayer glitching that happens when scrolling (by eliminating scrolling).
            // Showing the single album loses the current scroll position in the multi-album view.
            // Factoring the ScrollView out of AlbumCoverView does not keep the position.
            if (state.playing) {
                Image(nsImage: state.currentAlbum!.cover)
                    .resizable()
                    .border(Color.black)
                    .aspectRatio(contentMode: .fit)
                    .padding(PADDING)
            } else {
                AlbumCoverView(state: state)
            }

            // Bottom edge: playback and track selection controls.
            PlaybackControlView(state: state)
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

