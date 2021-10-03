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
            // Unfortunately this loses the position in the multi-album view when showing the single album.
            // It does crudely prevent the AVPlayer glitching that happens when scrolling by eliminating scrolling.
//            if (state.playing) {
//                Image(nsImage: state.currentAlbum!.cover)
//                    .resizable()
//                    .border(Color.black)
//                    .aspectRatio(contentMode: .fit)
//                    .padding(PADDING)
//            } else {

            AlbumCoverView(state: state)
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

