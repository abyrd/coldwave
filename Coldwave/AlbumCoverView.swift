//
//  AlbumCoverView.swift
//  Coldwave
//
//  Created by Andrew Byrd on 3/10/2021.
//

import SwiftUI
import Foundation

// Testing out Equatable for more efficient updates.
// LazyVGrid is too big to recompute at every interaction - factored out into Equatable struct.
struct AlbumCoverView : View, Equatable {

    let path: String
    let albums: [Album]
    let coverSize: CGFloat
    let currentAlbum: Album?
    let state: ColdwaveState // replace with separate CWPlayer class, with play methods. That's not observable state.

    init(state: ColdwaveState) {
        self.state = state
        path = state.path
        albums = state.albums
        coverSize = state.coverSize
        currentAlbum = state.currentAlbum
    }
    
    var body: some View {
        ScrollView {
            let _ = print("Computing potentially huge ScrollView")
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: coverSize))],
                spacing: GRID_SPACING
            ){
                // ForEach with an initial capital F is a SwiftUI view, not the language construct.
                ForEach(albums, id: \.self) { album in
                    SingleAlbumView(album: album, coverSize: coverSize, selected: currentAlbum == album)
                        .onTapGesture(count: 2) {
                            state.jumpToTrack(album: album, trackNumber: 0)
                        }
                }
            }.padding(PADDING)
        }
    }

    // Only re-render this view if the path or cover size change, or if a different album is selected.
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.path == rhs.path && lhs.coverSize == rhs.coverSize && lhs.currentAlbum == rhs.currentAlbum
    }

}

